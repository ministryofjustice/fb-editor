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

    // GLOBAL ALERT! app is a global object set in partials/_properties.html.erb
    this.labels = app.text.components[this.type];
  }

  disconnect() {
    if (this.orderableItemsController) {
      this.orderableItemsController.removeChild(this);
    }
  }

  orderValueChanged(newValue, oldValue) {
    if (newValue !== oldValue) {
      this.updateLabels();
      queueMicrotask(() => {
        this.dispatch("orderUpdated", { detail: { order: newValue } });
      });
    }
  }

  /**
   * Adds the move buttons to the element
   * Check for existence first, as the move action itself removes and reinserts
   * the elementinto the DOM causing connect() to be called again.
   **/
  appendButtons() {
    if (!this.hasUpButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button" 
                 aria-label="${this.upButtonLabel}"
                 class="icon-button icon-button--move icon-button--up" 
                 data-orderable-item-target="upButton" 
                 data-action="mousedown->orderable-item#moveUp:prevent 
                              keydown.enter->orderable-item#moveUp:prevent 
                              keyup.space->orderable-item#moveUp:prevent">
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                <path d="M8 20L16 12L24 20" stroke="currentColor" stroke-width="2"/>
            </svg>
        </button>`,
      );
    }
    if (!this.hasDownButtonTarget) {
      this.element.insertAdjacentHTML(
        "beforeend",
        `<button type="button"
                 aria-label="${this.downButtonLabel}"
                 class="icon-button icon-button--move icon-button--down"
                 data-orderable-item-target="downButton"
                 data-action="mousedown->orderable-item#moveDown:prevent 
                              keydown.enter->orderable-item#moveDown:prevent 
                              keyup.space->orderable-item#moveDown:prevent">
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                <path d="M24 12L16 20L8 12" stroke="currentColor" stroke-width="2"/>
            </svg>
        </button>`,
      );
    }
  }

  /**
   * Handler for the move down button
   * @param {Event} event
   * 1. This class is needed to ensure the buttons remain visible during the
   * move (when focus leaves the comopnent), so that they can be refocused after
   * moving
   *
   * 2. If navigating using the keyboard we keep the focus on the button to
   * facilitate repeated moves. If we reach the start/end focus is placed on the
   * opposite button as the trigger button will no longer be visible
   **/
  moveDown(event) {
    const keyboardEvent = event.detail == 0;
    const newIndex = this.currentIndex + 1;
    const nextItem = this.siblingElements[newIndex];

    this.element.classList.add(this.movingClass); // [1]
    nextItem.after(this.element);
    this.dispatch("move");

    if (keyboardEvent) {
      // [2]
      if (newIndex == this.siblingElements.length - 1) {
        this.upButtonTarget.focus();
      } else {
        this.downButtonTarget.focus();
      }
    }

    this.element.classList.remove(this.movingClass);
  }

  /**
   * Handler for the move up button
   * @param {Event} event
   * 1. This class is needed to ensure the buttons remain visible during the
   * move (when focus leaves the comopnent), so that they can be refocused after
   * moving
   *
   * 2. If navigating using the keyboard we keep the focus on the button to
   * facilitate repeated moves. If we reach the start/end focus is placed on the
   * opposite button as the trigger button will no longer be visible
   **/
  moveUp(event) {
    const keyboardEvent = event.detail == 0;
    const newIndex = this.currentIndex - 1;
    const previousItem = this.siblingElements[newIndex];

    this.element.classList.add(this.movingClass); // [1]
    previousItem.before(this.element);
    this.dispatch("move");

    if (keyboardEvent) {
      // [2]
      if (newIndex == 0) {
        this.downButtonTarget.focus();
      } else {
        this.upButtonTarget.focus();
      }
    }

    this.element.classList.remove(this.movingClass);
  }

  /**
   * Updates the (hidden) labels for the buttons for assistive tech users
   * Conditionals are required, as the orderValueChanged() callback is run before
   * connect() and thus the buttons won't have been inserted into the DOM yet
   **/
  updateLabels() {
    if (this.hasUpButtonTarget)
      this.upButtonTarget.setAttribute("aria-label", this.upButtonLabel);
    if (this.hasDownButtonTarget)
      this.downButtonTarget.setAttribute("aria-label", this.downButtonLabel);
  }

  get type() {
    return this.element.tagName == "EDITABLE-CONTENT" ? "content" : "component";
  }

  get upButtonLabel() {
    // Label from translations folder contains {{index}} placeholder
    return this.labels.move_up.replace("{{index}}", this.orderValue + 1);
  }

  get downButtonLabel() {
    // Label from translations folder contains {{index}} placeholder
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
