# frozen_string_literal: true

# AI usage statistics from discourse-ai plugin
# Shows total usage, favorite features, token consumption, etc.
module DiscourseRewind
  module Action
    class AiUsage < BaseReport
      def call
        return if !enabled?

        base_query = AiApiAuditLog.where(user_id: user.id).where(created_at: date)

        # Get aggregated stats in a single query
        stats =
          base_query.select(
            "COUNT(*) as total_requests",
            "COALESCE(SUM(request_tokens), 0) as total_request_tokens",
            "COALESCE(SUM(response_tokens), 0) as total_response_tokens",
            "COUNT(CASE WHEN response_tokens > 0 THEN 1 END) as successful_requests",
          ).take

        return if stats.total_requests == 0

        total_tokens = stats.total_request_tokens + stats.total_response_tokens
        success_rate =
          (
            if stats.total_requests > 0
              (stats.successful_requests.to_f / stats.total_requests * 100).round(1)
            else
              0
            end
          )

        # Most used features (top 5)
        feature_usage =
          base_query
            .group(:feature_name)
            .order("COUNT(*) DESC")
            .limit(5)
            .pluck(:feature_name, Arel.sql("COUNT(*)"))
            .to_h

        # Most used AI model (top 5)
        model_usage =
          base_query
            .where.not(language_model: nil)
            .group(:language_model)
            .order("COUNT(*) DESC")
            .limit(5)
            .pluck(:language_model, Arel.sql("COUNT(*)"))
            .to_h

        {
          data: {
            total_requests: stats.total_requests,
            total_tokens: total_tokens,
            request_tokens: stats.total_request_tokens,
            response_tokens: stats.total_response_tokens,
            feature_usage: feature_usage,
            model_usage: model_usage,
            success_rate: success_rate,
          },
          identifier: "ai-usage",
        }
      end

      def enabled?
        defined?(AiApiAuditLog) && SiteSetting.discourse_ai_enabled
      end
    end
  end
end
