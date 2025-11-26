import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

export default class ChatUsage extends Component {
  get favoriteChannels() {
    return this.args.report.data.favorite_channels ?? [];
  }

  <template>
    <div class="rewind-report-page -chat-usage">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.chat_usage.title"
        }}</h2>
      <div class="rewind-report-container">
        <div class="rewind-card scale">
          <div class="chat-usage__stat">
            {{icon "comment"}}
            <span class="chat-usage__label">{{i18n
                "discourse_rewind.reports.chat_usage.total_messages"
              }}</span>
            <span class="chat-usage__value">{{number
                @report.data.total_messages
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="chat-usage__stat">
            {{icon "envelope"}}
            <span class="chat-usage__label">{{i18n
                "discourse_rewind.reports.chat_usage.dm_messages"
              }}</span>
            <span class="chat-usage__value">{{number
                @report.data.dm_message_count
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="chat-usage__stat">
            {{icon "users"}}
            <span class="chat-usage__label">{{i18n
                "discourse_rewind.reports.chat_usage.unique_dm_channels"
              }}</span>
            <span class="chat-usage__value">{{number
                @report.data.unique_dm_channels
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="chat-usage__stat">
            {{icon "heart"}}
            <span class="chat-usage__label">{{i18n
                "discourse_rewind.reports.chat_usage.reactions_received"
              }}</span>
            <span class="chat-usage__value">{{number
                @report.data.total_reactions_received
              }}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="chat-usage__stat">
            {{icon "align-left"}}
            <span class="chat-usage__label">{{i18n
                "discourse_rewind.reports.chat_usage.avg_message_length"
              }}</span>
            <span
              class="chat-usage__value"
            >{{@report.data.avg_message_length}}</span>
          </div>
        </div>
      </div>

      {{#if this.favoriteChannels.length}}
        <h3 class="rewind-report-subtitle">{{i18n
            "discourse_rewind.reports.chat_usage.favorite_channels"
          }}</h3>
        <div class="rewind-report-container">
          {{#each this.favoriteChannels as |channel|}}
            <a
              class="rewind-card scale"
              href={{concat "/chat/c/-/" channel.channel_id}}
            >
              <div class="chat-usage__channel">
                <span
                  class="chat-usage__channel-name"
                >#{{channel.channel_name}}</span>
                <span class="chat-usage__channel-count">{{number
                    channel.message_count
                  }}
                  {{i18n "discourse_rewind.reports.chat_usage.messages"}}</span>
              </div>
            </a>
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}
