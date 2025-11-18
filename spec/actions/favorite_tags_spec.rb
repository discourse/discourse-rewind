# frozen_string_literal: true

RSpec.describe DiscourseRewind::Action::FavoriteTags do
  fab!(:date) { Date.new(2021).all_year }
  fab!(:user)

  before { SiteSetting.tagging_enabled = true }

  it "gets top 5 tags based on topic views" do
  end

  context "when in development mode" do
    before { Rails.env.stubs(:development?).returns(true) }

    it "returns fake data" do
      tags = call_report[:data]
      expect(tags.length).to eq(5)
      expect(tags.map { |t| t[:name] }).to eq(%w[cats dogs countries management things])
    end
  end
end
