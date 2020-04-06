import { withPluginApi } from "discourse/lib/plugin-api";
import showModal from "discourse/lib/show-modal";
import { iconHTML } from "discourse-common/lib/icon-library";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { avatarImg } from "discourse/widgets/post";

function launchBBB($elem, fullWindow) {
  const data = $elem.data();

  ajax("/bbb/create.json", {
    type: "POST",
    data: data
  })
    .then(res => {
      if (res.url) {
        if (fullWindow) {
          window.location.href = res.url;
        } else {
          $elem.children().hide();
          $elem.append(
            `<iframe src="${res.url}" allow="camera;microphone;fullscreen;speaker" width="690" height="500" style="border:none"></iframe>`
          );
        }
      }
    })
    .catch(function(error) {
      popupAjaxError(error);
    });
}

function attachButton($elem, fullWindow) {
  const buttonLabel = $elem.data("label") || I18n.t("bbb.launch");

  $elem.html(
    `<button class='launch-bbb btn'>${iconHTML(
      "video"
    )} ${buttonLabel}</button>`
  );
  $elem.find("button").on("click", () => launchBBB($elem, fullWindow));
}

function attachStatus($elem, helper) {
  const status = $elem.find(".bbb-status");
  const data = $elem.data();

  ajax(`/bbb/status/${data.meetingID}.json`).then(res => {
    if (res.usernames) {
      status.html(`On the call: ${res.usernames.join(", ")}`);
    }
  });
}

function attachBBB($elem, helper) {
  if (helper) {
    const siteSettings = Discourse.__container__.lookup("site-settings:main");
    const fullWindow = siteSettings.bbb_full_window;

    $elem.find("[data-wrap=discourse-bbb]").each((idx, val) => {
      attachButton($(val), fullWindow);
      $(val).append("<span class='bbb-status'></span>");
      attachStatus($(val), helper);
    });
  }
}

export default {
  name: "insert-bbb",

  initialize() {
    withPluginApi("0.8.31", api => {
      const currentUser = api.getCurrentUser();
      const siteSettings = api.container.lookup("site-settings:main");

      api.onToolbarCreate(toolbar => {
        if (siteSettings.bbb_staff_only && !currentUser.staff) {
          return;
        }

        toolbar.addButton({
          title: "bbb.composer_title",
          id: "insertBBB",
          group: "insertions",
          icon: "fab-bootstrap",
          perform: e =>
            showModal("insert-bbb").setProperties({ toolbarEvent: e })
        });
      });

      api.decorateCooked(attachBBB, { id: "discourse-bbb" });
    });
  }
};
