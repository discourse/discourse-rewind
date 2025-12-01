import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

export default class ChatUsage extends Component {
  get favoriteChannels() {
    return this.args.report.data.favorite_channels ?? [];
  }

  <template>
    <div class="rewind-report-page --chat-usage">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.chat_usage.title"
        }}</h2>

      <div class="chat-window">
        <div class="chat-window__header">
          <span class="chat-window__title">
            {{i18n "discourse_rewind.reports.chat_usage.channel_title"}}
          </span>
          <span class="chat-window__status">
            {{i18n "discourse_rewind.reports.chat_usage.status_online"}}
          </span>
        </div>

        <div class="chat-window__messages">
          <div class="chat-message --left">
            <div class="chat-message__avatar">🤖</div>
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.bot_name"}}
              </div>
              <div class="chat-message__text">
                {{htmlSafe
                  (i18n
                    "discourse_rewind.reports.chat_usage.message_1"
                    count=(number @report.data.total_messages)
                  )
                }}
              </div>
            </div>
          </div>

          <div class="chat-message --right">
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.you"}}
              </div>
              <div class="chat-message__text">
                {{i18n "discourse_rewind.reports.chat_usage.reply_1"}}
              </div>
            </div>
            <div class="chat-message__avatar">👤</div>
          </div>

          <div class="chat-message --left">
            <div class="chat-message__avatar">🤖</div>
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.bot_name"}}
              </div>
              <div class="chat-message__text">
                {{htmlSafe
                  (i18n
                    "discourse_rewind.reports.chat_usage.message_2"
                    dm_count=(number @report.data.dm_message_count)
                    channel_count=(number @report.data.unique_dm_channels)
                  )
                }}
              </div>
            </div>
          </div>

          <div class="chat-message --right">
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.you"}}
              </div>
              <div class="chat-message__text">
                {{i18n "discourse_rewind.reports.chat_usage.reply_2"}}
              </div>
            </div>
            <div class="chat-message__avatar">👤</div>
          </div>

          <div class="chat-message --left">
            <div class="chat-message__avatar">🤖</div>
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.bot_name"}}
              </div>
              <div class="chat-message__text">
                {{htmlSafe
                  (i18n
                    "discourse_rewind.reports.chat_usage.message_3"
                    count=(number @report.data.total_reactions_received)
                  )
                }}
              </div>
            </div>
          </div>

          <div class="chat-message --right">
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.you"}}
              </div>
              <div class="chat-message__text">
                {{i18n "discourse_rewind.reports.chat_usage.reply_3"}}
              </div>
            </div>
            <div class="chat-message__avatar">👤</div>
          </div>

          <div class="chat-message --left">
            <div class="chat-message__avatar">🤖</div>
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.bot_name"}}
              </div>
              <div class="chat-message__text">
                {{htmlSafe
                  (i18n
                    "discourse_rewind.reports.chat_usage.message_4"
                    length=@report.data.avg_message_length
                  )
                }}
              </div>
            </div>
          </div>

          {{#if this.favoriteChannels.length}}
            <div class="chat-message --left">
              <div class="chat-message__avatar">🤖</div>
              <div class="chat-message__bubble">
                <div class="chat-message__author">
                  {{i18n "discourse_rewind.reports.chat_usage.bot_name"}}
                </div>
                <div class="chat-message__text">
                  {{i18n "discourse_rewind.reports.chat_usage.message_5"}}
                </div>
                <div class="chat-message__channels">
                  {{#each this.favoriteChannels as |channel|}}
                    <a
                      class="chat-channel-link"
                      href={{concat "/chat/c/-/" channel.channel_id}}
                    >
                      <span
                        class="chat-channel-link__name"
                      >#{{channel.channel_name}}</span>
                      <span class="chat-channel-link__count">
                        {{number channel.message_count}}
                      </span>
                    </a>
                  {{/each}}
                </div>
              </div>
            </div>
          {{/if}}

          <div class="chat-message --right">
            <div class="chat-message__bubble">
              <div class="chat-message__author">
                {{i18n "discourse_rewind.reports.chat_usage.you"}}
              </div>
              <img
                src="/plugins/discourse-rewind/images/dancing_baby.gif"
                alt={{i18n
                  "discourse_rewind.reports.chat_usage.dancing_baby_alt"
                }}
                class="chat-message__gif"
              />
            </div>
            <div class="chat-message__avatar">👤</div>
          </div>
        </div>
      </div>
    </div>
  </template>
}
