import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static targets = ["upButton", "downButton"];
  static classes = ["moving"];
  static ancestor = "movable-items";

  connect() {
    useControllerName(this);
    useAncestry(this);
    Promise.resolve().then(() => {
      this.render();
    });
  }

  disconnect() {
    this.movableItemsController.removeChild(this);
  }

  render() {
    if (!this.hasUpButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button" class="icon-button icon-button--up" data-movable-item-target="upButton" data-action="movable-item#moveUp:prevent">Up</button>`,
      );
    }
    if (!this.hasDownButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button" class="icon-button icon-button--down" data-movable-item-target="downButton" data-action="movable-item#moveDown:prevent">Down</button>`,
      );
    }
  }

  moveDown(event) {
    const keyboardEvent = event.detail == 0;
    const newIndex = this.currentIndex + 1;
    const nextItem = this.siblingElements[newIndex];

    this.element.classList.add(this.movingClass);
    nextItem.after(this.element);
    this.dispatch("move");

    if (keyboardEvent) {
      if (newIndex == this.siblingElements.length - 1) {
        this.upButtonTarget.focus();
      } else {
        this.downButtonTarget.focus();
      }
    }

    this.element.classList.remove(this.movingClass);
  }

  moveUp(event) {
    const keyboardEvent = event.detail == 0;
    const newIndex = this.currentIndex - 1;
    const previousItem = this.siblingElements[newIndex];

    this.element.classList.add(this.movingClass);
    previousItem.before(this.element);
    this.dispatch("move");

    if (keyboardEvent) {
      if (newIndex == 0) {
        this.downButtonTarget.focus();
      } else {
        this.upButtonTarget.focus();
      }
    }

    this.element.classList.remove(this.movingClass);
  }

  get currentIndex() {
    return this.siblingElements.indexOf(this.element);
  }

  get maxIndexValue() {
    return this.siblingElements.length - 1;
  }

  get siblingElements() {
    return this.movableItemsController.movableItemTargets;
  }
}
