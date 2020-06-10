import Controller from "@ember/controller";
import ModalFunctionality from "discourse/mixins/modal-functionality";
import discourseComputed from "discourse-common/utils/decorators";
import { isEmpty } from "@ember/utils";

export default Controller.extend(ModalFunctionality, {
  keyDown(e) {
    if (e.keyCode === 13) {
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
  },

  onShow() {
    this.setProperties({
      meetingID: "",
      attendeePW: "",
      moderatorPW: "",
      buttonText: "",
      mobileIframe: false,
      desktopIframe: true,
    });
  },

  randomID() {
    return Math.random()
      .toString(36)
      .slice(-8);
  },

  @discourseComputed("meetingID")
  insertDisabled(meetingID) {
    return isEmpty(meetingID);
  },

  actions: {
    insert() {
      const btnTxt = this.buttonText ? ` label="${this.buttonText}"` : "";
      this.toolbarEvent.addText(
        `[wrap=discourse-bbb meetingID="${
          this.meetingID
        }"${btnTxt} attendeePW="${this.randomID()}" moderatorPW="${this.randomID()}" mobileIframe="${
          this.mobileIframe
        }" desktopIframe="${this.desktopIframe}"][/wrap]`
      );
      this.send("closeModal");
    },
    cancel() {
      this.send("closeModal");
    },
  },
});
