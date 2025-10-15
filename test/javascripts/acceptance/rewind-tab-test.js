import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance, fakeTime } from "discourse/tests/helpers/qunit-helpers";

acceptance("DiscourseRewind | rewind tab", function (needs) {
  needs.user();
  needs.settings({ discourse_rewind_enabled: true });

  test("shows the tab in january", async function (assert) {
    const clock = fakeTime("2022-01-10 12:00:00", null, false);

    await visit("/my/activity");

    assert
      .dom(".user-nav__activity-rewind")
      .exists("rewind tab is visible in January");

    clock.restore();
  });

  test("shows the tab in december", async function (assert) {
    const clock = fakeTime("2022-12-05 12:00:00", null, false);

    await visit("/my/activity");

    assert
      .dom(".user-nav__activity-rewind")
      .exists("rewind tab is visible in December");

    clock.restore();
  });

  test("doesn't show the tab in november", async function (assert) {
    const clock = fakeTime("2022-11-24 12:00:00", null, false);

    await visit("/my/activity");

    assert
      .dom(".user-nav__activity-rewind")
      .doesNotExist("rewind tab is not visible in November");

    clock.restore();
  });
});
