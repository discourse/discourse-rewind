import Component from "@glimmer/component";
import { action } from "@ember/object";
import concatClass from "discourse/helpers/concat-class";
import { i18n } from "discourse-i18n";

const ROWS = 7;
const COLS = 53;

export default class ActivityCalendar extends Component {
  get rowsArray() {
    const data = this.args.report.data;
    let rowsArray = [];

    for (let r = 0; r < ROWS; r++) {
      let rowData = [];
      for (let c = 0; c < COLS; c++) {
        const index = c * ROWS + r;
        rowData.push(data[index] ? data[index] : "");
      }
      rowsArray.push(rowData);
    }

    return rowsArray;
  }

  @action
  getAbbreviatedMonth(monthIndex) {
    return moment().month(monthIndex).format("MMM");
  }

  @action
  computeClass(count) {
    if (!count) {
      return "-empty";
    } else if (count < 10) {
      return "-low";
    } else if (count < 20) {
      return "-medium";
    } else {
      return "-high";
    }
  }

  <template>
    <div class="rewind-report-page -activity-calendar">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.activity_calendar.title"
        }}</h2>

      <div class="rewind-card">
        <table class="rewind-calendar">
          <thead>
            <tr>
              <td
                colspan="5"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 0}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 1}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 2}}</td>
              <td
                colspan="5"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 3}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 4}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 5}}</td>
              <td
                colspan="5"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 6}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 7}}</td>
              <td
                colspan="5"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 8}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 9}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 10}}</td>
              <td
                colspan="4"
                class="activity-header-cell"
              >{{this.getAbbreviatedMonth 11}}</td>
            </tr>
          </thead>
          <tbody>
            {{#each this.rowsArray as |row|}}
              <tr>
                {{#each row as |cell|}}
                  <td
                    data-date={{cell.date}}
                    title={{cell.date}}
                    class={{concatClass
                      "rewind-calendar-cell"
                      (this.computeClass cell.post_count)
                    }}
                  ></td>
                {{/each}}
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
    </div>
  </template>
}
