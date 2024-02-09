import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static targets = ["upButton", "downButton"];
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
    console.log("movable-item render");
    if (!this.hasUpButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button" class="" data-movable-item-target="upButton" data-action="movable-item#moveUp:prevent">Up</button>`,
      );
    }
    if (!this.hasDownButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button" class="" data-movable-item-target="downButton" data-action="movable-item#moveDown:prevent">Down</button>`,
      );
    }
  }

  moveDown(event) {
    const button = event.target;
    console.log(button);
    const newIndex = this.currentIndex + 1;
    const nextItem = this.siblingElements[newIndex];

    this.element.classList.add("moving");

    nextItem.after(this.element);
    this.dispatch("move");
    button.focus();
    this.element.classList.remove("moving");
  }

  moveUp(event) {
    const button = event.target;
    console.log(button);
    const newIndex = this.currentIndex - 1;
    const previousItem = this.siblingElements[newIndex];

    this.element.classList.add("moving");

    previousItem.before(this.element);

    this.dispatch("move");
    button.focus();
    this.element.classList.remove("moving");
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
