import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { namespaceCamelize } from "../utilities/string-helpers";

export default class extends Controller {
  static targets = ["upButton", "downButton"];

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
    useControllerName(this);
    this.connectAncestor();
  }

  disconnect() {
    this.removeChild(this);
  }

  connectAncestor() {
    console.log("connecting ancestors");
    console.log(this.ancestorIdentifier);
    console.log(this.ancestorElement);
    if (this.ancestorElement) {
      console.log("ancestors found");
      this[this.ancestorControllerKey] =
        this.application.getControllerForElementAndIdentifier(
          this.ancestorElement,
          this.ancestorIdentifier,
        );
    }
    console.log(this[this.ancestorControllerKey]);
    if (this.hasAncestorController) {
      this[this.ancestorControllerKey]?.addChild(this);
    }
  }

  get ancestorElement() {
    return this.element.closest(
      `[data-controller*="${this.ancestorIdentifier}"]`,
    );
  }

  get hasAncestorController() {
    return this[this.ancestorControllerKey] !== "undefined";
  }

  get _childControllers() {
    return this[this.childControllersKey];
  }

  get ancestorControllerKey() {
    return `${this.ancestorName}Controller`;
  }

  get childControllersKey() {
    return `${this.childName}Controllers`;
  }

  get ancestorIdentifier() {
    return this.constructor.ancestor || `${this.identifier}s`;
  }

  get childIdentifier() {
    return (
      this.constructor.children ||
      `${this.identifier.slice(0, this.identifier.length - 1)}`
    );
  }

  get ancestorName() {
    return namespaceCamelize(this.ancestorIdentifier);
  }

  get childName() {
    return namespaceCamelize(this.childIdentifier);
  }

  addChild(childController) {
    this[this.childControllersKey] = [
      ...(this._childControllers || []),
      childController,
    ];
  }

  removeChild(childController) {
    const index = this._childControllers.indexOf(childController);

    if (index > -1) {
      this._childControllers.splice(index, 1);
    }
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

  get parentController() {
    const el = this.element.closest('[data-controller*="movable-items"]');
    return el.movableItemsController;
  }

  get maxIndexValue() {
    return this.parentController.movableItemTargets.length - 1;
  }
}
