import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static targets = ["upButton", "downButton"];
  static ancestor = "movable-items";

  initialize() {
    this.element.insertAdjacentHTML(
      "beforeend",
      `<button type="button" data-movable-item-target="upButton" data-action="movable-item#moveUp:prevent">Up</button>`,
    );
    this.element.insertAdjacentHTML(
      "beforeend",
      `<button type="button" data-movable-item-target="downButton" data-action="movable-item#moveDown:prevent">Down</button>`,
    );
  }

  connect() {
    useControllerName(this);
    useAncestry(this);
  }

  disconnect() {
    this.movableItemsController.removeChild(this);
  }

  upButtonTargetConnected() {
    requestAnimationFrame(() => {
      this.updateButtonVisibilty();
    });
  }

  downButtonConnected() {
    requestAnimationFrame(() => {
      this.updateButtonVisibilty();
    });
  }

  moveDown(event) {
    const button = event.target;
    const currentIndex = this.siblingElements.indexOf(this.element);
    const newIndex = currentIndex + 1;
    const nextItem = this.siblingElements[newIndex];

    nextItem.after(this.element);
    button.focus();

    this.dispatch("move");
  }

  moveUp(event) {
    const button = event.target;
    const currentIndex = this.siblingElements.indexOf(this.element);
    const newIndex = currentIndex - 1;
    const previousItem = this.siblingElements[newIndex];

    previousItem.before(this.element);
    button.focus();

    this.dispatch("move");
  }

  updateButtonVisibilty() {
    const index = this.siblingElements.indexOf(this.element);
    index == 0
      ? this.upButtonTarget.setAttribute("hidden", "")
      : this.upButtonTarget.removeAttribute("hidden");
    index == this.maxIndexValue
      ? this.downButtonTarget.setAttribute("hidden", "")
      : this.downButtonTarget.removeAttribute("hidden");
  }

  get maxIndexValue() {
    return this.siblingElements.length - 1;
  }

  get siblingElements() {
    return this.movableItemsController.movableItemTargets;
  }
}
