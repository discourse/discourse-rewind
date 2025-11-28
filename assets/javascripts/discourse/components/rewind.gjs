import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
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
  @tracked totalAvailable = 0;
  @tracked loadingNextReport = false;

  BUFFER_SIZE = 3;

  // Arrow function for event listener - maintains 'this' binding
  handleScroll = () => {
    if (!this.scrollWrapper || this.loadingRewind) {
      return;
    }

    const scrollTop = this.scrollWrapper.scrollTop;
    const scrollHeight = this.scrollWrapper.scrollHeight;
    const clientHeight = this.scrollWrapper.clientHeight;

    // Trigger preload when scrolled 70% through content
    const scrollPercentage = (scrollTop + clientHeight) / scrollHeight;
    if (scrollPercentage > 0.7) {
      this.preloadNextReports();
    }
  };

  @action
  registerScrollWrapper(element) {
    this.scrollWrapper = element;
    this.scrollWrapper.addEventListener("scroll", this.handleScroll);
  }

  @action
  async loadRewind() {
    try {
      this.loadingRewind = true;
      const response = await ajax("/rewinds");
      this.rewind = response.reports;
      this.totalAvailable = response.total_available;

      // Preload next report to maintain buffer
      this.preloadNextReports();
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.loadingRewind = false;
    }
  }

  @action
  async preloadNextReports() {
    // Load reports to maintain BUFFER_SIZE ahead of current position
    const currentIndex = this.rewind.length;
    const targetIndex = currentIndex + this.BUFFER_SIZE;

    if (
      this.loadingNextReport ||
      currentIndex >= this.totalAvailable ||
      targetIndex > this.totalAvailable
    ) {
      return;
    }

    try {
      this.loadingNextReport = true;
      const response = await ajax(`/rewinds/${currentIndex}`);
      this.rewind = [...this.rewind, response.report];

      // Continue preloading if we haven't reached buffer size yet
      if (this.rewind.length < targetIndex) {
        this.preloadNextReports();
      }
    } catch (e) {
      // Silently fail for preloading - user already has content to view
      // eslint-disable-next-line no-console
      console.error("Failed to preload report:", e);
    } finally {
      this.loadingNextReport = false;
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

  @action
  cleanup() {
    if (this.scrollWrapper) {
      this.scrollWrapper.removeEventListener("scroll", this.handleScroll);
    }
  }

  <template>
    <div
      class={{concatClass
        "rewind-container"
        (if this.fullScreen "-fullscreen")
      }}
      {{didInsert this.loadRewind}}
      {{willDestroy this.cleanup}}
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
