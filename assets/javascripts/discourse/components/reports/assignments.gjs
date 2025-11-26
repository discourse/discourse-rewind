import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

const Assignments = <template>
  <div class="rewind-report-page -assignments">
    <h2 class="rewind-report-title">{{i18n
        "discourse_rewind.reports.assignments.title"
      }}</h2>
    <div class="rewind-report-container">
      <div class="rewind-card scale">
        <div class="assignments__stat">
          {{icon "user-check"}}
          <span class="assignments__label">{{i18n
              "discourse_rewind.reports.assignments.total_assigned"
            }}</span>
          <span class="assignments__value">{{number
              @report.data.total_assigned
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="assignments__stat">
          {{icon "check"}}
          <span class="assignments__label">{{i18n
              "discourse_rewind.reports.assignments.completed"
            }}</span>
          <span class="assignments__value">{{number
              @report.data.completed
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="assignments__stat">
          {{icon "clock"}}
          <span class="assignments__label">{{i18n
              "discourse_rewind.reports.assignments.pending"
            }}</span>
          <span class="assignments__value">{{number
              @report.data.pending
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="assignments__stat">
          {{icon "hand-point-right"}}
          <span class="assignments__label">{{i18n
              "discourse_rewind.reports.assignments.assigned_by_user"
            }}</span>
          <span class="assignments__value">{{number
              @report.data.assigned_by_user
            }}</span>
        </div>
      </div>

      <div class="rewind-card scale">
        <div class="assignments__stat">
          {{icon "percent"}}
          <span class="assignments__label">{{i18n
              "discourse_rewind.reports.assignments.completion_rate"
            }}</span>
          <span
            class="assignments__value"
          >{{@report.data.completion_rate}}%</span>
        </div>
      </div>
    </div>
  </div>
</template>;

export default Assignments;
