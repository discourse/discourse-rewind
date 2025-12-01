# frozen_string_literal: true

module DiscourseRewind
  # Service responsible to fetch a rewind for a username/year.
  #
  # @example
  #  ::DiscourseRewind::Rewind::Fetch.call(
  #    guardian: guardian,
  #    params: { year: 2023, username: 'codinghorror' }
  #  )
  #
  class FetchReports
    include Service::Base

    # @!method self.call(guardian:, params:)
    #   @param [Guardian] guardian
    #   @param [Hash] params
    #   @option params [Integer] :year of the rewind
    #   @option params [Integer] :username of the rewind
    #   @option params [Integer] :count number of reports to fetch (optional, defaults to 3)
    #   @return [Service::Base::Context]

    CACHE_DURATION = Rails.env.development? ? 10.seconds : 5.minutes
    INITIAL_REPORT_COUNT = 3

    # order matters
    REPORTS = [
      Action::TopWords,
      Action::ReadingTime,
      Action::Reactions,
      Action::Fbff,
      Action::MostViewedTags,
      Action::MostViewedCategories,
      Action::BestTopics,
      Action::BestPosts,
      Action::ActivityCalendar,
      Action::TimeOfDayActivity,
      Action::NewUserInteractions,
      Action::ChatUsage,
      Action::AiUsage,
      Action::FavoriteGifs,
      Action::Assignments,
      Action::Invites,
    ]

    model :year
    model :date
    model :enabled_reports
    model :reports
    model :total_available

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

    def fetch_enabled_reports(date:, guardian:, year:)
      # Generate all reports and filter out nils (disabled/empty reports)
      # Cache the full list to maintain consistent indices across requests
      key = "rewind:#{guardian.user.username}:#{year}:all_reports"
      cached_list = Discourse.redis.get(key)

      return MultiJson.load(cached_list, symbolize_keys: true) if cached_list

      reports =
        REPORTS.filter_map do |report_class|
          begin
            report_class.call(date:, user: guardian.user, guardian:)
          rescue => e
            Rails.logger.error("Failed to generate report #{report_class.name}: #{e.message}")
            nil
          end
        end

      # Cache the complete enabled reports list
      Discourse.redis.setex(key, CACHE_DURATION, MultiJson.dump(reports))
      reports
    end

    def fetch_total_available(enabled_reports:)
      enabled_reports.length
    end

    def fetch_reports(enabled_reports:, params:)
      count = params[:count]&.to_i || INITIAL_REPORT_COUNT
      count = [[count, 1].max, enabled_reports.length].min

      enabled_reports.first(count)
    end
  end
end
