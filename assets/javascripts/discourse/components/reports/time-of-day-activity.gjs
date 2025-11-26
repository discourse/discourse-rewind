import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

export default class TimeOfDayActivity extends Component {
  get activityByHour() {
    return this.args.report.data.activity_by_hour ?? {};
  }

  get mostActiveHour() {
    return this.args.report.data.most_active_hour;
  }

  get personality() {
    return this.args.report.data.personality;
  }

  get maxActivity() {
    const counts = Object.values(this.activityByHour);
    return Math.max(...counts, 1);
  }

  get personalityIcon() {
    if (this.personality?.type === "early_bird") {
      return "sun";
    } else if (this.personality?.type === "night_owl") {
      return "moon";
    }
    return "clock";
  }

  @action
  formatHour(hour) {
    const hourNum = parseInt(hour, 10);
    const period = hourNum >= 12 ? "PM" : "AM";
    const displayHour =
      hourNum === 0 ? 12 : hourNum > 12 ? hourNum - 12 : hourNum;
    return `${displayHour}${period}`;
  }

  @action
  computeBarHeight(count) {
    const percentage = (count / this.maxActivity) * 100;
    return htmlSafe(`height: ${percentage}%`);
  }

  @action
  isActiveHour(hour) {
    return parseInt(hour, 10) === this.mostActiveHour;
  }

  <template>
    <div class="rewind-report-page -time-of-day-activity">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.time_of_day_activity.title"
        }}</h2>

      {{#if this.personality}}
        <div class="rewind-card">
          <div class="time-of-day__personality">
            {{icon this.personalityIcon}}
            <span class="time-of-day__personality-type">{{i18n
                (concat
                  "discourse_rewind.reports.time_of_day_activity.personality."
                  this.personality.type
                )
              }}</span>
            {{#if this.personality.percentage}}
              <span class="time-of-day__personality-percentage">
                ({{this.personality.percentage}}%)</span>
            {{/if}}
          </div>
        </div>
      {{/if}}

      <div class="rewind-card">
        <div class="time-of-day__chart">
          {{#each-in this.activityByHour as |hour count|}}
            <div
              class="time-of-day__bar-container
                {{if (this.isActiveHour hour) 'active'}}"
            >
              <div
                class="time-of-day__bar"
                style={{this.computeBarHeight count}}
                title="{{this.formatHour hour}}: {{number count}} activities"
              ></div>
              <span class="time-of-day__hour-label">{{this.formatHour
                  hour
                }}</span>
            </div>
          {{/each-in}}
        </div>
      </div>

      <div class="time-of-day__legend">
        <div class="time-of-day__legend-item">
          {{icon "star"}}
          <span>{{i18n
              "discourse_rewind.reports.time_of_day_activity.most_active"
              hour=(this.formatHour this.mostActiveHour)
            }}</span>
        </div>
      </div>
    </div>
  </template>
}
