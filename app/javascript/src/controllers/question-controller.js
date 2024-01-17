import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["upButton", "downButton"];
  static values = {
    index: Number,
    content: Object,
  };

  initialize() {
    this.element.insertAdjacentHTML(
      "beforeend",
      `<button type="button" data-question-target="upButton" data-action="questions#moveUp:prevent">Up</button>`,
    );
    this.element.insertAdjacentHTML(
      "beforeend",
      `<button type="button" data-question-target="downButton" data-action="questions#moveDown:prevent">Down</button>`,
    );
  }

  connect() {
    console.log("questioN controller connected");
    this.element[`${this.identifier}Controller`] = this;
  }

  upButtonTargetConnected() {
    console.log("up button connected");
    this.updateButtonVisibilty();
  }

  downButtonConnected() {
    console.log("down button says hello");
    this.updateButtonVisibilty();
  }

  indexValueChanged(oldValue, newValue) {
    console.log("changed");
    console.log(oldValue);
    console.log(newValue);
    this.updateButtonVisibilty();
    // update data
    console.log(this.contentValue);
    this.contentValue = Object.assign(this.contentValue, { index: newValue });
    console.log(this.contentValue);
    // trigger saveRequired
    document.dispatchEvent(
      new CustomEvent("SaveRequired", {
        bubbles: true,
      }),
    );
  }

  updateButtonVisibilty() {
    this.indexValue == 0
      ? this.upButtonTarget.setAttribute("hidden", "")
      : this.upButtonTarget.removeAttribute("hidden");
    this.indexValue == this.questionsController.questionTargets.length - 1
      ? this.downButtonTarget.setAttribute("hidden", "")
      : this.downButtonTarget.removeAttribute("hidden");
  }

  get questionsController() {
    const el = this.element.closest('[data-controller="questions"]');
    console.log(el);
    return el.questionsController;
  }
}
