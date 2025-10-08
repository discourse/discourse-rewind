# frozen_string_literal: true

RSpec.describe DiscourseRewind::RewindsController do
  before { SiteSetting.discourse_rewind_enabled = true }

  describe "#show" do
    fab!(:current_user, :user)

    before { sign_in(current_user) }

    context "when out of valid month" do
      before { freeze_time DateTime.parse("2022-11-24") }

      it "returns 404" do
        get "/rewinds.json"

        expect(response.status).to eq(404)
      end
    end

    context "when in valid month" do
      before { freeze_time DateTime.parse("2022-12-24") }

      it "returns 200" do
        get "/rewinds.json"

        expect(response.status).to eq(200)
      end
    end
  end
end
