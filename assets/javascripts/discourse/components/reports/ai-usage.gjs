import Component from "@glimmer/component";
import { action, get } from "@ember/object";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { i18n } from "discourse-i18n";

export default class AiUsage extends Component {
  get totalRequests() {
    return this.args.report.data.total_requests ?? 0;
  }

  get totalTokens() {
    return this.args.report.data.total_tokens ?? 0;
  }

  get successRate() {
    return this.args.report.data.success_rate ?? 0;
  }

  get featureUsage() {
    return Object.entries(this.args.report.data.feature_usage ?? {});
  }

  get modelUsage() {
    return Object.entries(this.args.report.data.model_usage ?? {});
  }

  get maxFeatureCount() {
    const counts = this.featureUsage.map(([, count]) => count);
    return Math.max(...counts, 1);
  }

  get maxModelCount() {
    const counts = this.modelUsage.map(([, count]) => count);
    return Math.max(...counts, 1);
  }

  @action
  computePercentageStyle(count, max) {
    const percentage = (count / max) * 100;
    return htmlSafe(`width: ${percentage}%`);
  }

  @action
  formatFeatureName(featureName) {
    return featureName.replace(/_/g, " ");
  }

  <template>
    <div class="rewind-report-page -ai-usage">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.ai_usage.title"
        }}</h2>
      <div class="rewind-report-container">
        <div class="rewind-card scale">
          <div class="ai-usage__stat">
            {{icon "robot"}}
            <span class="ai-usage__label">{{i18n
                "discourse_rewind.reports.ai_usage.total_requests"
              }}</span>
            <span class="ai-usage__value">{{number this.totalRequests}}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="ai-usage__stat">
            {{icon "file-lines"}}
            <span class="ai-usage__label">{{i18n
                "discourse_rewind.reports.ai_usage.total_tokens"
              }}</span>
            <span class="ai-usage__value">{{number this.totalTokens}}</span>
          </div>
        </div>

        <div class="rewind-card scale">
          <div class="ai-usage__stat">
            {{icon "check-circle"}}
            <span class="ai-usage__label">{{i18n
                "discourse_rewind.reports.ai_usage.success_rate"
              }}</span>
            <span class="ai-usage__value">{{this.successRate}}%</span>
          </div>
        </div>
      </div>

      {{#if this.featureUsage.length}}
        <h3 class="rewind-report-subtitle">{{i18n
            "discourse_rewind.reports.ai_usage.favorite_features"
          }}</h3>
        <div class="rewind-card">
          <div class="ai-usage__chart">
            {{#each this.featureUsage as |entry|}}
              <div class="ai-usage__bar-row">
                <span class="ai-usage__bar-label">{{this.formatFeatureName
                    (get entry "0")
                  }}</span>
                <span class="ai-usage__bar-count">{{get entry "1"}}</span>
                <div
                  class="ai-usage__bar"
                  style={{this.computePercentageStyle
                    (get entry "1")
                    this.maxFeatureCount
                  }}
                ></div>
              </div>
            {{/each}}
          </div>
        </div>
      {{/if}}

      {{#if this.modelUsage.length}}
        <h3 class="rewind-report-subtitle">{{i18n
            "discourse_rewind.reports.ai_usage.favorite_models"
          }}</h3>
        <div class="rewind-card">
          <div class="ai-usage__chart">
            {{#each this.modelUsage as |entry|}}
              <div class="ai-usage__bar-row">
                <span class="ai-usage__bar-label">{{get entry "0"}}</span>
                <span class="ai-usage__bar-count">{{get entry "1"}}</span>
                <div
                  class="ai-usage__bar"
                  style={{this.computePercentageStyle
                    (get entry "1")
                    this.maxModelCount
                  }}
                ></div>
              </div>
            {{/each}}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
