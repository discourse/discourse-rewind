# frozen_string_literal: true

# Forum Best Friend Forever ranking
# Score is informative only, do not show in UI
module DiscourseRewind
  module Action
    class Fbff < BaseReport
      MAX_SUMMARY_RESULTS = 50
      LIKE_SCORE = 1
      REPLY_SCORE = 10

      def call
        most_liked_users =
          like_query(date)
            .where(acting_user_id: user.id)
            .group(:user_id)
            .order("COUNT(*) DESC")
            .limit(MAX_SUMMARY_RESULTS)
            .pluck("user_actions.user_id, COUNT(*)")
            .map { |user_id, count| { user_id => count } }
            .reduce({}, :merge)

        most_liked_by_users =
          like_query(date)
            .where(user: user)
            .group(:acting_user_id)
            .order("COUNT(*) DESC")
            .limit(MAX_SUMMARY_RESULTS)
            .pluck("acting_user_id, COUNT(*)")
            .map { |acting_user_id, count| { acting_user_id => count } }
            .reduce({}, :merge)

        users_who_most_replied_me =
          post_query(user, date)
            .where(posts: { user_id: user.id })
            .group("replies.user_id")
            .order("COUNT(*) DESC")
            .limit(MAX_SUMMARY_RESULTS)
            .pluck("replies.user_id, COUNT(*)")
            .map { |user_id, count| { user_id => count } }
            .reduce({}, :merge)

        users_i_most_replied =
          post_query(user, date)
            .where("replies.user_id = ?", user.id)
            .group("posts.user_id")
            .order("COUNT(*) DESC")
            .limit(MAX_SUMMARY_RESULTS)
            .pluck("posts.user_id, COUNT(*)")
            .map { |user_id, count| { user_id => count } }
            .reduce({}, :merge)

        #TODO include chat?

        fbffs = [
          apply_score(most_liked_users, LIKE_SCORE),
          apply_score(most_liked_by_users, LIKE_SCORE),
          apply_score(users_who_most_replied_me, REPLY_SCORE),
          apply_score(users_i_most_replied, REPLY_SCORE),
        ]

        fbff_id =
          fbffs
            .flatten
            .inject { |h1, h2| h1.merge(h2) { |_, v1, v2| v1 + v2 } }
            &.sort_by { |_, v| -v }
            &.first
            &.first

        return if !fbff_id

        {
          data: {
            fbff: BasicUserSerializer.new(User.find(fbff_id), root: false).as_json,
            yourself: BasicUserSerializer.new(user, root: false).as_json,
          },
          identifier: "fbff",
        }
      end

      def post_query(user, date)
        Post
          .joins(:topic)
          .includes(:topic)
          .where(
            "posts.post_type IN (?)",
            Topic.visible_post_types(user, include_moderator_actions: false),
          )
          .joins(
            "INNER JOIN posts replies ON posts.topic_id = replies.topic_id AND posts.reply_to_post_number = replies.post_number",
          )
          .joins(
            "INNER JOIN topics ON replies.topic_id = topics.id AND topics.archetype <> 'private_message'",
          )
          .joins(
            "AND replies.post_type IN (#{Topic.visible_post_types(user, include_moderator_actions: false).join(",")})",
          )
          .where("replies.created_at BETWEEN ? AND ?", date.first, date.last)
          .where("replies.user_id <> posts.user_id")
      end

      def like_query(date)
        UserAction
          .joins(:target_topic, :target_post)
          .where(created_at: date)
          .where(action_type: UserAction::WAS_LIKED)
      end

      def apply_score(users, score)
        users.map { |user_id, count| { user_id => count * score } }
      end
    end
  end
end
