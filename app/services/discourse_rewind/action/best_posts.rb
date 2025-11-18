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
            .order("like_count DESC NULLS LAST, created_at ASC")
            .limit(3)
            .select(:post_number, :topic_id, :like_count, :reply_count, :raw, :cooked)
            .map do |post|
              {
                post_number: post.post_number,
                topic_id: post.topic_id,
                like_count: post.like_count,
                reply_count: post.reply_count,
                excerpt:
                  post.excerpt(200, { strip_links: true, remap_emoji: true, keep_images: true }),
              }
            end

        { data: best_posts, identifier: "best-posts" }
      end
    end
  end
end
