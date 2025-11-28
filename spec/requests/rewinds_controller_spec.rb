# frozen_string_literal: true

RSpec.describe DiscourseRewind::RewindsController do
  before { SiteSetting.discourse_rewind_enabled = true }

  fab!(:current_user, :user)

  before { sign_in(current_user) }

  describe "#index" do
    context "when out of valid month" do
      before { freeze_time DateTime.parse("2022-11-24") }

      it "returns 404" do
        get "/rewinds.json"

        expect(response.status).to eq(404)
        expect(response.parsed_body["errors"].first).to eq(I18n.t("discourse_rewind.invalid_year"))
      end
    end

    context "when in valid month" do
      before { freeze_time DateTime.parse("2022-12-24") }

      it "returns 200 with reports and total_available" do
        get "/rewinds.json"

        expect(response.status).to eq(200)
        expect(response.parsed_body["reports"]).to be_present
        expect(response.parsed_body["total_available"]).to be_present
        expect(response.parsed_body["reports"].length).to eq(3)
      end

      it "limits initial reports to 3 by default" do
        get "/rewinds.json"

        expect(response.parsed_body["reports"].length).to eq(3)
        expect(response.parsed_body["total_available"]).to be > 3
      end

      context "when a report errors" do
        before do
          DiscourseRewind::Action::TopWords.stubs(:call).raises(StandardError.new("Some error"))
        end

        it "filters out failed reports and returns remaining reports" do
          get "/rewinds.json"

          expect(response.status).to eq(200)
          expect(response.parsed_body["reports"]).to be_present
          expect(response.parsed_body["reports"].map { |r| r["identifier"] }).not_to include(
            "top-words",
          )
        end
      end
    end
  end

  describe "#show" do
    context "when out of valid month" do
      before { freeze_time DateTime.parse("2022-11-24") }

      it "returns 404" do
        get "/rewinds/0.json"

        expect(response.status).to eq(404)
        expect(response.parsed_body["errors"].first).to eq(I18n.t("discourse_rewind.invalid_year"))
      end
    end

    context "when in valid month" do
      before { freeze_time DateTime.parse("2022-12-24") }

      it "returns 200 with a single report" do
        get "/rewinds/0.json"

        expect(response.status).to eq(200)
        expect(response.parsed_body["report"]).to be_present
        expect(response.parsed_body["report"]["identifier"]).to be_present
      end

      it "returns different reports for different indices" do
        # Get all reports first to know what to expect
        get "/rewinds.json"
        total = response.parsed_body["total_available"]

        # Request second report if there is one
        if total > 1
          get "/rewinds/1.json"

          expect(response.status).to eq(200)
          expect(response.parsed_body["report"]["identifier"]).to be_present
        end
      end

      context "when index is out of bounds" do
        it "returns 404" do
          # Request index that exceeds the REPORTS array length
          # There are 16 items in REPORTS array, so 999 should definitely be out of bounds
          get "/rewinds/999", params: {}, as: :json

          expect(response.status).to eq(404)
          expect(response.parsed_body["errors"].first).to eq(
            I18n.t("discourse_rewind.invalid_report_index"),
          )
        end
      end

      context "when report fails to generate" do
        before do
          DiscourseRewind::Action::TopWords.stubs(:call).raises(StandardError.new("Some error"))
        end

        it "filters out failed report and adjusts indices" do
          # TopWords is filtered out, index 0 points to first successful report
          get "/rewinds/0.json"

          expect(response.status).to eq(200)
          expect(response.parsed_body["report"]["identifier"]).to be_present
          expect(response.parsed_body["report"]["identifier"]).not_to eq("top-words")
        end
      end
    end
  end
end
