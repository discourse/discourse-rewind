import Component from "@glimmer/component";
import { concat, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import emoji from "discourse/helpers/emoji";
import discourseLater from "discourse-common/lib/later";

const MYSTERY_EMOJIS = [
  "mag", // 🔍
  "question", // ❓
  "8ball", // 🎱
  "crystal_ball", // 🔮
  "crescent_moon", // 🌙
];

const BACKGROUND_COLORS = [
  [
    "251, 245, 175",
    "40, 171, 226",
    "12, 166, 78",
    "240, 121, 74",
    "232, 74, 81",
  ],
  [
    "197, 193, 140",
    "39, 137, 178",
    "17, 138, 68",
    "188, 105, 65",
    "183, 64, 70",
  ],
];

export default class WordCard extends Component {
  get randomStyle() {
    return `--rand: ${Math.random()}`;
  }

  get mysteryData() {
    return {
      emoji: MYSTERY_EMOJIS[this.args.index],
      color: `--mystery-color-light: ${
        BACKGROUND_COLORS[0][this.args.index]
      }; --mystery-color-dark: ${BACKGROUND_COLORS[1][this.args.index]};`,
    };
  }

  @action
  registerCardContainer(element) {
    this.cardContainer = element;
  }

  @action
  handleClick() {
    this.cardContainer.classList.toggle("flipped");
  }

  @action
  handleLeave() {
    const cardContainer = this.cardContainer;
    cardContainer.classList.toggle("mouseleave");
    discourseLater(() => {
      cardContainer.classList.remove("mouseleave");
    }, 100);
  }

  <template>
    <div
      {{on "click" (fn this.handleClick)}}
      {{on "mouseleave" (fn this.handleLeave)}}
      class="rewind-card__wrapper"
      style={{concat this.randomStyle "; " this.mysteryData.color ";"}}
      {{didInsert this.registerCardContainer}}
    >
      <div class="rewind-card__inner">
        <div class="rewind-card -front">
          <span class="rewind-card__image tl">{{emoji
              this.mysteryData.emoji
            }}</span>
          <span class="rewind-card__image cr">{{emoji
              this.mysteryData.emoji
            }}</span>
          <span class="rewind-card__image br">{{emoji
              this.mysteryData.emoji
            }}</span>
        </div>
        <div class="rewind-card -back">
          <span class="rewind-card__title">{{@word}}</span>
          <span class="rewind-card__data">{{@count}}x</span>
        </div>
      </div>
    </div>
  </template>
}
