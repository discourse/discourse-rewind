import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import avatar from "discourse/helpers/bound-avatar-template";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

export default class Invites extends Component {
  get mostActiveInvitee() {
    return this.args.report.data.most_active_invitee;
  }

  <template>
    <div class="rewind-report-page -invites">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.invites.title"
        }}</h2>
      <div class="rewind-report-container">
        <div class="rewind-card scale">
          <div class="invites__stat">
            {{icon "envelope"}}
            <span class="invites__label">{{i18n
                "discourse_rewind.reports.invites.total_invites"
              }}</span>
            <span class="invites__value">{{number
                @report.data.total_invites
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="invites__stat">
            {{icon "user-check"}}
            <span class="invites__label">{{i18n
                "discourse_rewind.reports.invites.redeemed"
              }}</span>
            <span class="invites__value">{{number
                @report.data.redeemed_count
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="invites__stat">
            {{icon "percent"}}
            <span class="invites__label">{{i18n
                "discourse_rewind.reports.invites.redemption_rate"
              }}</span>
            <span
              class="invites__value"
            >{{@report.data.redemption_rate}}%</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="invites__stat">
            {{icon "star"}}
            <span class="invites__label">{{i18n
                "discourse_rewind.reports.invites.avg_trust_level"
              }}</span>
            <span class="invites__value">{{@report.data.avg_trust_level}}</span>
          </div>
        </div>
      </div>

      <h3 class="rewind-report-subtitle">{{i18n
          "discourse_rewind.reports.invites.invitee_impact"
        }}</h3>
      <div class="rewind-report-container">
        <div class="rewind-card scale">
          <div class="invites__stat">
            {{icon "file-lines"}}
            <span class="invites__label">{{i18n
                "discourse_rewind.reports.invites.invitee_posts"
              }}</span>
            <span class="invites__value">{{number
                @report.data.invitee_post_count
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="invites__stat">
            {{icon "list"}}
            <span class="invites__label">{{i18n
                "discourse_rewind.reports.invites.invitee_topics"
              }}</span>
            <span class="invites__value">{{number
                @report.data.invitee_topic_count
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="invites__stat">
            {{icon "heart"}}
            <span class="invites__label">{{i18n
                "discourse_rewind.reports.invites.invitee_likes"
              }}</span>
            <span class="invites__value">{{number
                @report.data.invitee_like_count
              }}</span>
          </div>
        </div>
      </div>

      {{#if this.mostActiveInvitee}}
        <h3 class="rewind-report-subtitle">{{i18n
            "discourse_rewind.reports.invites.most_active_invitee"
          }}</h3>
        <div class="rewind-card">
          <a
            href={{concat "/u/" this.mostActiveInvitee.username}}
            class="invites__active-user"
          >
            {{avatar
              this.mostActiveInvitee.avatar_template
              "large"
              username=this.mostActiveInvitee.username
              name=this.mostActiveInvitee.name
            }}
            <div class="invites__active-user-info">
              <span
                class="invites__username"
              >{{this.mostActiveInvitee.username}}</span>
              {{#if this.mostActiveInvitee.name}}
                <span
                  class="invites__name"
                >{{this.mostActiveInvitee.name}}</span>
              {{/if}}
            </div>
          </a>
        </div>
      {{/if}}
    </div>
  </template>
}
