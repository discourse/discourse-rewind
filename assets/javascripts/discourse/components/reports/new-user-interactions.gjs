import Component from "@glimmer/component";
import { i18n } from "discourse-i18n";

export default class NewUserInteractions extends Component {
  get wavyWords() {
    const num = this.args.report.data.unique_new_users;
    const memberText =
      num === 1
        ? i18n("discourse_rewind.reports.new_user_interactions.member_singular")
        : i18n("discourse_rewind.reports.new_user_interactions.member_plural");
    const text = `${num.toLocaleString()} ${memberText}`;
    const words = text.split(" ");
    return words.map((word) => word.split(""));
  }

  <template>
    <div class="rewind-report-page --new-user-interactions">
      <div class="wordart-container">
        <div class="wordart-text">your contributions helped</div>
        <div class="wordart-3d">
          {{#each this.wavyWords as |word|}}
            <span class="wordart-word">
              {{#each word as |char|}}
                <span class="wordart-letter">{{char}}</span>
              {{/each}}
            </span>
          {{/each}}
        </div>
      </div>
    </div>
  </template>
}
