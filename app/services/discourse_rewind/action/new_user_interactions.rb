# frozen_string_literal: true

# Tracks how much this user interacted with new users (created this year)
# Shows veteran mentorship and community building behavior
module DiscourseRewind
  module Action
    class NewUserInteractions < BaseReport
      FakeData = {
        data: {
          total_interactions: 127,
          likes_given: 45,
          replies_to_new_users: 62,
          mentions_to_new_users: 20,
          topics_with_new_users: 8,
          unique_new_users: 24,
          new_users_count: 156,
        },
        identifier: "new-user-interactions",
      }

      def call
        return FakeData if Rails.env.development?
        year_start = Date.new(date.first.year, 1, 1)

        # Find users who created accounts this year
        new_user_ids =
          User
            .real
            .where("created_at >= ? AND created_at <= ?", year_start, date.last)
            .where("id != ?", user.id)
            .pluck(:id)

        return if new_user_ids.empty?

        # Count likes given to new users
        likes_scope =
          UserAction.where(
            acting_user_id: user.id,
            user_id: new_user_ids,
            action_type: UserAction::WAS_LIKED,
          ).where(created_at: date)
        likes_given = likes_scope.count
        liked_user_ids = likes_scope.distinct.pluck(:user_id)

        # Count replies to new users' posts
        replies_scope =
          Post
            .joins(
              "INNER JOIN posts AS parent_posts ON posts.reply_to_post_number = parent_posts.post_number AND posts.topic_id = parent_posts.topic_id",
            )
            .where(posts: { user_id: user.id, deleted_at: nil, created_at: date })
            .where("parent_posts.user_id": new_user_ids)
        replies_to_new_users = replies_scope.count
        replied_user_ids = replies_scope.distinct.pluck("parent_posts.user_id")

        # Count topics created by user that new users participated in
        topics_with_new_users =
          Topic
            .joins(:posts)
            .where(topics: { user_id: user.id, deleted_at: nil })
            .where(posts: { user_id: new_user_ids, deleted_at: nil })
            .where(topics: { created_at: date })
            .distinct
            .count

        # Count direct messages/mentions to new users
        mentions_scope =
          Post
            .joins(
              "INNER JOIN user_actions ON user_actions.target_post_id = posts.id AND user_actions.action_type = #{UserAction::MENTION}",
            )
            .where(posts: { user_id: user.id, deleted_at: nil, created_at: date })
            .where(user_actions: { user_id: new_user_ids })
        mentions_to_new_users = mentions_scope.distinct.count
        mentioned_user_ids = mentions_scope.distinct.pluck("user_actions.user_id")

        # Unique new users interacted with
        unique_new_users = (liked_user_ids + replied_user_ids + mentioned_user_ids).uniq.count

        total_interactions = likes_given + replies_to_new_users + mentions_to_new_users

        return if total_interactions == 0

        {
          data: {
            total_interactions: total_interactions,
            likes_given: likes_given,
            replies_to_new_users: replies_to_new_users,
            mentions_to_new_users: mentions_to_new_users,
            topics_with_new_users: topics_with_new_users,
            unique_new_users: unique_new_users,
            new_users_count: new_user_ids.count,
          },
          identifier: "new-user-interactions",
        }
      end
    end
  end
end
