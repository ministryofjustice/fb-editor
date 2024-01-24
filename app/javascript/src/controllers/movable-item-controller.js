import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";
import { namespaceCamelize } from "../utilities/string-helpers";

export default class extends Controller {
  static targets = ["upButton", "downButton"];
  static ancestor = "movable-items";

  initialize() {
    this.element.insertAdjacentHTML(
      "beforeend",
      `<button type="button" data-question-target="upButton" data-action="orderable-item#decrement:prevent">Up</button>`,
    );
    this.element.insertAdjacentHTML(
      "beforeend",
      `<button type="button" data-question-target="downButton" data-action="orderable-item#increment:prevent">Down</button>`,
    );
  }

  connect() {
    console.log("moveable-item controller connected");
    useControllerName(this);
    useAncestry(this);
  }

  disconnect() {
    this.removeChild(this);
  }

  upButtonTargetConnected() {
    console.log("up button connected");
    this.updateButtonVisibilty();
  }

  downButtonConnected() {
    console.log("down button says hello");
    this.updateButtonVisibilty();
  }

  updateButtonVisibilty() {
    this.indexValue == 0
      ? this.upButtonTarget.setAttribute("hidden", "")
      : this.upButtonTarget.removeAttribute("hidden");
    this.indexValue == this.maxIndexValue
      ? this.downButtonTarget.setAttribute("hidden", "")
      : this.downButtonTarget.removeAttribute("hidden");
  }

  get maxIndexValue() {
    return this.selfAndSiblingControllers.length - 1;
  }
}
