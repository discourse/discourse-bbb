import Component from "@glimmer/component";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class InsertBBB extends Component {
  @tracked meetingID = "";
  @tracked attendeePW = "";
  @tracked moderatorPW = "";
  @tracked buttonText = "";
  @tracked mobileIframe = false;
  @tracked desktopIframe = true;

  @action
  keyDown(e) {
    if (e.keyCode === 13) {
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
  }

  @action
  onShow() {
    this.meetingID = "";
    this.attendeePW = "";
    this.moderatorPW = "";
    this.buttonText = "";
    this.mobileIframe = false;
    this.desktopIframe = true;
  }

  randomID() {
    return Math.random().toString(36).slice(-8);
  }

  @discourseComputed("meetingID")
  get insertDisabled() {
    return isEmpty(this.meetingID);
  }

  @action
  insert() {
    const btnTxt = this.buttonText ? ` label="${this.buttonText}"` : "";
    // Note: Replace the following line with the Glimmer equivalent for your use case
    // this.toolbarEvent.addText(`[wrap=discourse-bbb meetingID="${this.meetingID}"${btnTxt} attendeePW="${this.randomID()}" moderatorPW="${this.randomID()}" mobileIframe="${this.mobileIframe}" desktopIframe="${this.desktopIframe}"][/wrap]`);
    this.args.toolbarEvent.addText(
      `[wrap=discourse-bbb meetingID="${
        this.meetingID
      }"${btnTxt} attendeePW="${this.randomID()}" moderatorPW="${this.randomID()}" mobileIframe="${
        this.mobileIframe
      }" desktopIframe="${this.desktopIframe}"][/wrap]`
    );
    // Note: Replace the following line with the Glimmer equivalent for your use case
    // this.send('closeModal');
    this.args.closeModal();
  }

  @action
  cancel() {
    // Note: Replace the following line with the Glimmer equivalent for your use case
    // this.send('closeModal');
    this.args.closeModal();
  }
}
