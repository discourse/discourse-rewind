# frozen_string_literal: true

module ::DiscourseRewind
  class RewindsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    requires_login

    def show
      DiscourseRewind::FetchReports.call(service_params) do
        on_model_not_found(:year) { raise Discourse::NotFound }
        on_model_not_found(:user) { raise Discourse::NotFound }
        on_success { |reports:| render json: MultiJson.dump(reports), status: :ok }
      end
    end
  end
end
