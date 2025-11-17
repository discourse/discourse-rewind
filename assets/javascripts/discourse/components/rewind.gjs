import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import ActivityCalendar from "discourse/plugins/discourse-rewind/discourse/components/reports/activity-calendar";
import BestPosts from "discourse/plugins/discourse-rewind/discourse/components/reports/best-posts";
import BestTopics from "discourse/plugins/discourse-rewind/discourse/components/reports/best-topics";
import FBFF from "discourse/plugins/discourse-rewind/discourse/components/reports/fbff";
import RewindHeader from "discourse/plugins/discourse-rewind/discourse/components/reports/header";
import MostViewedCategories from "discourse/plugins/discourse-rewind/discourse/components/reports/most-viewed-categories";
import MostViewedTags from "discourse/plugins/discourse-rewind/discourse/components/reports/most-viewed-tags";
import Reactions from "discourse/plugins/discourse-rewind/discourse/components/reports/reactions";
import ReadingTime from "discourse/plugins/discourse-rewind/discourse/components/reports/reading-time";
import TopWords from "discourse/plugins/discourse-rewind/discourse/components/reports/top-words";

export default class Rewind extends Component {
  @tracked rewind = [];
  @tracked fullScreen = true;
  @tracked loadingRewind = false;

  @action
  registerScrollWrapper(element) {
    this.scrollWrapper = element;
  }

  @action
  async loadRewind() {
    try {
      this.loadingRewind = true;
      this.rewind = await ajax("/rewinds");
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.loadingRewind = false;
    }
  }

  @action
  toggleFullScreen() {
    this.fullScreen = !this.fullScreen;
  }

  @action
  handleEscape(event) {
    if (this.fullScreen && event.key === "Escape") {
      this.fullScreen = false;
    }
  }

  @action
  handleBackdropClick(event) {
    if (this.fullScreen && event.target === event.currentTarget) {
      this.fullScreen = false;
    }
  }

  @action
  registerRewindContainer(element) {
    this.rewindContainer = element;
  }

  <template>
    <div
      class={{concatClass
        "rewind-container"
        (if this.fullScreen "-fullscreen")
      }}
      {{didInsert this.loadRewind}}
      {{on "keydown" this.handleEscape}}
      {{on "click" this.handleBackdropClick}}
      {{didInsert this.registerRewindContainer}}
      tabindex="0"
    >
      <div class="rewind">
        <RewindHeader />
        {{#if this.loadingRewind}}
          <div class="rewind-loader">
            <div class="spinner small"></div>
            <div class="rewind-loader__text">
              {{i18n "discourse_rewind.loading"}}
            </div>
          </div>
        {{else}}
          <DButton
            class="btn-default rewind__exit-fullscreen-btn --special-kbd"
            @icon={{if this.fullScreen "discourse-compress" "discourse-expand"}}
            @action={{this.toggleFullScreen}}
          />
          <div
            class="rewind__scroll-wrapper"
            {{didInsert this.registerScrollWrapper}}
          >

            {{#each this.rewind as |report|}}
              <div class={{concatClass "rewind-report" report.identifier}}>
                {{#if (eq report.identifier "fbff")}}
                  <FBFF @report={{report}} />
                {{else if (eq report.identifier "reactions")}}
                  <Reactions @report={{report}} />
                {{else if (eq report.identifier "top-words")}}
                  <TopWords @report={{report}} />
                {{else if (eq report.identifier "best-posts")}}
                  <BestPosts @report={{report}} />
                {{else if (eq report.identifier "best-topics")}}
                  <BestTopics @report={{report}} />
                {{else if (eq report.identifier "activity-calendar")}}
                  <ActivityCalendar @report={{report}} />
                {{else if (eq report.identifier "most-viewed-tags")}}
                  <MostViewedTags @report={{report}} />
                {{else if (eq report.identifier "reading-time")}}
                  <ReadingTime @report={{report}} />
                {{else if (eq report.identifier "most-viewed-categories")}}
                  <MostViewedCategories @report={{report}} />
                {{/if}}
              </div>
            {{/each}}
          </div>

          {{#if this.showPrev}}
            <DButton
              class="rewind__prev-btn"
              @icon="chevron-left"
              @action={{this.prev}}
            />
          {{/if}}

          {{#if this.showNext}}
            <DButton
              class="rewind__next-btn"
              @icon="chevron-right"
              @action={{this.next}}
            />
          {{/if}}
        {{/if}}
      </div>
    </div>
  </template>
}
