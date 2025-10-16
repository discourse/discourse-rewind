# frozen_string_literal: true

# Assignment statistics using discourse-assign plugin data
# Shows how many assignments, completed, pending, etc.
module DiscourseRewind
  module Action
    class Assignments < BaseReport
      def call
        return if !enabled?

        # Assignments made to the user
        assigned_topics =
          TopicAllowedUser
            .joins(:topic)
            .joins(
              "INNER JOIN assignments ON assignments.topic_id = topics.id AND assignments.assigned_to_id = #{user.id}",
            )
            .where("assignments.created_at BETWEEN ? AND ?", date.first, date.last)
            .where("assignments.assigned_to_type = 'User'")
            .pluck(:topic_id)
            .uniq

        total_assigned = assigned_topics.count

        # Completed assignments (topics that were assigned and then closed or unassigned)
        completed_count =
          TopicAllowedUser
            .joins(:topic)
            .joins(
              "INNER JOIN assignments ON assignments.topic_id = topics.id AND assignments.assigned_to_id = #{user.id}",
            )
            .where("assignments.created_at BETWEEN ? AND ?", date.first, date.last)
            .where("assignments.assigned_to_type = 'User'")
            .where("topics.closed = true OR assignments.updated_at > assignments.created_at")
            .distinct
            .count

        # Currently pending (still open and assigned)
        pending_count =
          Assignment
            .where(assigned_to_id: user.id, assigned_to_type: "User")
            .joins(:topic)
            .where("topics.closed = false")
            .count

        # Assignments made by the user to others
        assigned_by_user =
          Assignment
            .where("assignments.created_at BETWEEN ? AND ?", date.first, date.last)
            .joins(
              "INNER JOIN posts ON posts.topic_id = assignments.topic_id AND posts.user_id = #{user.id}",
            )
            .distinct
            .count(:topic_id)

        {
          data: {
            total_assigned: total_assigned,
            completed: completed_count,
            pending: pending_count,
            assigned_by_user: assigned_by_user,
            completion_rate:
              total_assigned > 0 ? (completed_count.to_f / total_assigned * 100).round(1) : 0,
          },
          identifier: "assignments",
        }
      end

      def enabled?
        defined?(Assignment) && SiteSetting.assign_enabled
      end
    end
  end
end
