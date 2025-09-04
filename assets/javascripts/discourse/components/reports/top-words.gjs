import { i18n } from "discourse-i18n";
import WordCard from "discourse/plugins/discourse-rewind/discourse/components/reports/top-words/word-card";

const WordCards = <template>
  <div class="rewind-report-page -top-words">
    <div class="rewind-report-container">
      <h2 class="rewind-report-title">{{i18n
          "discourse_rewind.reports.top_words.title"
        }}</h2>
      <div class="cards-container">
        {{#each @report.data as |entry index|}}
          <WordCard
            @word={{entry.word}}
            @count={{entry.score}}
            @index={{index}}
          />
        {{/each}}
      </div>
    </div>
  </div>
</template>;

export default WordCards;
