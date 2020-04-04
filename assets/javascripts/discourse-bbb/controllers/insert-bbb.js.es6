import Controller from "@ember/controller";
import ModalFunctionality from "discourse/mixins/modal-functionality";

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
      buttonText: ""
    });
  },

  actions: {
    insert() {
      const btnTxt = this.buttonText ? ` label="${this.buttonText}"` : "";
      this.toolbarEvent.addText(
        `[wrap=discourse-bbb meetingID="${this.meetingID}"${btnTxt} attendeePW="${this.attendeePW}" moderatorPW="${this.moderatorPW}"][/wrap]`
      );
      this.send("closeModal");
    },
    cancel() {
      this.send("closeModal");
    }
  }
});
