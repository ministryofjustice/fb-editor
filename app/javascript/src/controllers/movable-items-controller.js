import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { namespaceCamelize } from "../utilities/string-helpers";

export default class extends Controller {
  static targets = ["movable-item"];

  connect() {
    useControllerName(this);
    connectAncestor;
  }

  connectAncestor() {
    console.log("connecting ancestors");
    if (this.ancestorElement) {
      console.log("ancestors found");
      console.log(this.ancestorIdentifier);
      console.log(this.ancestorElement);
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
}
