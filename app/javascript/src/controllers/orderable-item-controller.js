import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static targets = ["upButton", "downButton"];
  static classes = ["moving"];
  // Default order set so that the first item (index 0) still dispatches an orderUpdated event when connected.
  static values = {
    order: { type: Number, default: 9999 },
  };
  static ancestor = "orderable-items";

  connect() {
    useControllerName(this);
    useAncestry(this);

    this.labels = app.text.components;

    queueMicrotask(() => {
      this.render();
    });
  }

  disconnect() {
    this.orderableItemsController.removeChild(this);
  }

  orderValueChanged(newValue, oldValue) {
    if (newValue !== oldValue) {
      this.updateLabels();
      queueMicrotask(() => {
        this.dispatch("orderUpdated", { detail: { order: newValue } });
      });
    }
  }

  render() {
    if (!this.hasUpButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button" class="icon-button icon-button--move icon-button--up" data-orderable-item-target="upButton" data-action="orderable-item#moveUp:prevent">${this.upButtonLabel}</button>`,
      );
    }
    if (!this.hasDownButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button" class="icon-button icon-button--move icon-button--down" data-orderable-item-target="downButton" data-action="orderable-item#moveDown:prevent">${this.downButtonLabel}</button>`,
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

  updateLabels() {
    if (this.hasUpButtonTarget)
      this.upButtonTarget.innerText = this.upButtonLabel;
    if (this.hasDownButtonTarget)
      this.downButtonTarget.innerText = this.downButtonLabel;
  }

  get upButtonLabel() {
    return this.labels.move_up.replace("{{index}}", this.orderValue + 1);
  }

  get downButtonLabel() {
    return this.labels.move_down.replace("{{index}}", this.orderValue + 1);
  }

  get currentIndex() {
    return this.siblingElements.indexOf(this.element);
  }

  get maxIndexValue() {
    return this.siblingElements.length - 1;
  }

  get siblingElements() {
    return this.orderableItemsController.orderableItemTargets;
  }
}
