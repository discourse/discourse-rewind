# frozen_string_literal: true

module DiscourseRewind
  # Service responsible to fetch a single report by index.
  #
  # @example
  #  ::DiscourseRewind::FetchReport.call(
  #    guardian: guardian,
  #    index: 3
  #  )
  #
  class FetchReport
    include Service::Base

    # @!method self.call(guardian:, params:)
    #   @param [Guardian] guardian
    #   @param [Hash] params
    #   @option params [Integer] :index the report index
    #   @return [Service::Base::Context]

    CACHE_DURATION = Rails.env.development? ? 10.seconds : 5.minutes

    model :year
    model :date
    model :report_class
    model :report

    private

    def fetch_year
      current_date = Time.zone.now
      current_month = current_date.month
      current_year = current_date.year

      case current_month
      when 1
        current_year - 1
      when 12
        current_year
      else
        # Otherwise it's impossible to test in browser unless you're
        # in December or January
        if Rails.env.development?
          current_year
        else
          false
        end
      end
    end

    def fetch_date(params:, year:)
      Date.new(year).all_year
    end

    def fetch_report_class(date:, guardian:, year:, params:)
      # Use the same cached all_reports list as FetchReports
      # If not cached, generate it now
      key = "rewind:#{guardian.user.username}:#{year}:all_reports"
      cached_list = Discourse.redis.get(key)

      all_reports =
        if cached_list
          MultiJson.load(cached_list, symbolize_keys: true)
        else
          # Generate all reports and cache them
          reports =
            FetchReports::REPORTS.filter_map do |report_class|
              begin
                report_class.call(date:, user: guardian.user, guardian:)
              rescue => e
                Rails.logger.error("Failed to generate report #{report_class.name}: #{e.message}")
                nil
              end
            end
          Discourse.redis.setex(key, CACHE_DURATION, MultiJson.dump(reports))
          reports
        end

      # Access index from params data object (params.index) or hash (params[:index])
      index = (params[:index] || params.index).to_i

      return false if index < 0 || index >= all_reports.length

      all_reports[index]
    end

    def fetch_report(report_class:)
      # Report is already generated and cached in the all_reports list
      report_class
    end
  end
end
