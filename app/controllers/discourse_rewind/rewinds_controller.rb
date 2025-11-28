# frozen_string_literal: true

module ::DiscourseRewind
  class RewindsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login

    def index
      DiscourseRewind::FetchReports.call(service_params) do
        on_model_not_found(:year) do
          raise Discourse::NotFound.new(nil, custom_message: "discourse_rewind.invalid_year")
        end
        on_model_not_found(:reports) do
          raise Discourse::NotFound.new(nil, custom_message: "discourse_rewind.report_failed")
        end
        on_success do |reports:, total_available:|
          render json: { reports: reports, total_available: total_available }, status: :ok
        end
      end
    end

    def show
      DiscourseRewind::FetchReport.call(service_params) do
        on_model_not_found(:year) do
          raise Discourse::NotFound.new(nil, custom_message: "discourse_rewind.invalid_year")
        end
        on_model_not_found(:report_class) do
          raise Discourse::NotFound.new(
                  nil,
                  custom_message: "discourse_rewind.invalid_report_index",
                )
        end
        on_model_not_found(:report) do
          raise Discourse::NotFound.new(nil, custom_message: "discourse_rewind.report_failed")
        end
        on_success { |report:| render json: { report: report }, status: :ok }
      end
    end
  end
end
