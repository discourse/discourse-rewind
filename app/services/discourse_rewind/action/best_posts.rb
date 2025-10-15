# frozen_string_literal: true

module DiscourseRewind
  module Action
    class BestPosts < BaseReport
      def call
        best_posts =
          Post
            .where(user_id: user.id)
            .where(created_at: date)
            .where(deleted_at: nil)
            .where("post_number > 1")
            .order("like_count DESC NULLS LAST")
            .limit(3)
            .pluck(:post_number, :topic_id, :like_count, :reply_count, :raw, :cooked)
            .map do |post_number, topic_id, like_count, reply_count, raw, cooked|
              {
                post_number: post_number,
                topic_id: topic_id,
                like_count: like_count,
                reply_count: reply_count,
                raw: raw,
                cooked: cooked,
              }
            end

        { data: best_posts, identifier: "best-posts" }
      end
    end
  end
end
