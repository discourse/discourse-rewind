import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

const NewUserInteractions = <template>
  <div class="rewind-report-page -new-user-interactions">
    <h2 class="rewind-report-title">{{i18n
        "discourse_rewind.reports.new_user_interactions.title"
      }}</h2>
    <div class="rewind-report-subtitle">{{i18n
        "discourse_rewind.reports.new_user_interactions.subtitle"
        count=@report.data.new_users_count
      }}</div>
    <div class="rewind-report-container">
      <div class="rewind-card scale">
        <div class="new-user-interactions__stat">
          {{icon "handshake"}}
          <span class="new-user-interactions__label">{{i18n
              "discourse_rewind.reports.new_user_interactions.total_interactions"
            }}</span>
          <span class="new-user-interactions__value">{{number
              @report.data.total_interactions
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="new-user-interactions__stat">
          {{icon "users"}}
          <span class="new-user-interactions__label">{{i18n
              "discourse_rewind.reports.new_user_interactions.unique_new_users"
            }}</span>
          <span class="new-user-interactions__value">{{number
              @report.data.unique_new_users
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="new-user-interactions__stat">
          {{icon "heart"}}
          <span class="new-user-interactions__label">{{i18n
              "discourse_rewind.reports.new_user_interactions.likes_given"
            }}</span>
          <span class="new-user-interactions__value">{{number
              @report.data.likes_given
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="new-user-interactions__stat">
          {{icon "reply"}}
          <span class="new-user-interactions__label">{{i18n
              "discourse_rewind.reports.new_user_interactions.replies"
            }}</span>
          <span class="new-user-interactions__value">{{number
              @report.data.replies_to_new_users
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="new-user-interactions__stat">
          {{icon "at"}}
          <span class="new-user-interactions__label">{{i18n
              "discourse_rewind.reports.new_user_interactions.mentions"
            }}</span>
          <span class="new-user-interactions__value">{{number
              @report.data.mentions_to_new_users
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="new-user-interactions__stat">
          {{icon "comments"}}
          <span class="new-user-interactions__label">{{i18n
              "discourse_rewind.reports.new_user_interactions.topics_with_new_users"
            }}</span>
          <span class="new-user-interactions__value">{{number
              @report.data.topics_with_new_users
            }}</span>
        </div>
      </div>
    </div>
  </div>
</template>;

export default NewUserInteractions;
