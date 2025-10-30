# frozen_string_literal: true

RSpec.describe(DiscourseRewind::FetchReports) do
  describe ".call" do
    subject(:result) { described_class.call(**dependencies) }

    fab!(:current_user, :user)

    let(:guardian) { Guardian.new(current_user) }
    let(:dependencies) { { guardian: } }

    context "when in january" do
      before { freeze_time DateTime.parse("2021-01-22") }

      it "computes the correct previous year" do
        expect(result.year).to eq(2020)
      end
    end

    context "when in december" do
      before { freeze_time DateTime.parse("2021-12-22") }

      it "computes the correct previous year" do
        expect(result.year).to eq(2021)
      end
    end

    context "when out of valid months december" do
      before { freeze_time DateTime.parse("2021-02-22") }

      it { is_expected.to fail_to_find_a_model(:year) }
    end

    context "when reports is cached" do
      before { freeze_time DateTime.parse("2021-12-22") }

      it "returns the cached reports" do
        expect(result.reports.length).to eq(16)

        allow(DiscourseRewind::Action::TopWords).to receive(:call)
        expect(result.reports.length).to eq(16)
        expect(DiscourseRewind::Action::TopWords).to_not have_received(:call)
      end
    end

    context "when reports is not cached" do
      before do
        freeze_time DateTime.parse("2021-01-22")
        Discourse.redis.del("rewind:#{current_user.username}:2020")
      end

      it "returns the reports" do
        allow(DiscourseRewind::Action::TopWords).to receive(:call)
        expect(result.reports.length).to eq(16)
        expect(DiscourseRewind::Action::TopWords).to have_received(:call)
      end
    end
  end
end
