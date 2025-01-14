import { concat } from "@ember/helper";
import { i18n } from "discourse-i18n";

const FavoriteCategories = <template>
  {{#if @report.data.length}}
    <div class="rewind-report-page -favorite-categories">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.favorite_categories.title"
          count=@report.data.length
        }}</h2>
      <div class="rewind-report-container">
        {{#each @report.data as |data|}}
          <a href={{concat "/c/-/" data.category_id}} class="rewind-card">
            <p
              class="favorite-categories__category"
              href={{concat "/c/-/" data.category_id}}
            >{{data.name}}</p>
          </a>
        {{/each}}
      </div>
    </div>
  {{/if}}
</template>;

export default FavoriteCategories;
