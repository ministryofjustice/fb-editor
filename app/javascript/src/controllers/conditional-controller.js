import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "fieldset",
    "title",
    "deleteButton",
    "expression",
    "destination",
  ];

  static outlets = ["conditionals-status"];

  static values = {
    index: Number,
    title: String,
    deleteLabel: String,
    destinationLabel: String,
  };

  connect() {
    // Attach a reference to the controller to the element
    this.element[`${this.identifier}Controller`] = this;
  }

  expressionTargetConnected() {
    Promise.resolve().then(() => {
      this.updateFieldLabelsForExpressions();
    });
  }

  expressionTargetDisconnected(element) {
    this.fieldsetTarget.focus();
  }

  indexValueChanged(newValue, oldValue) {
    if (newValue !== oldValue) {
      this.updateTitle();
      this.updateDeleteButtonLabel();
      if (this.hasDestinationTarget) {
        this.updateDestinationLabel();
      }
      Promise.resolve().then(() => {
        this.updateFieldLabelsForExpressions();
      });
    }
  }

  focusNewExpression(event) {
    if (event.detail.additionType != "expression") return;

    const element = event.detail.element;
    Promise.resolve().then(() => {
      element.expressionController.questionTarget.focus();
    });
  }

  get title() {
    return `${this.titleValue} ${this.indexValue}`;
  }

  delete() {
    this.#destroy();
  }

  deleteWithConfirmation() {
    document.dispatchEvent(
      new CustomEvent("ConfirmBranchConditionalRemoval", {
        detail: {
          action: () => {
            this.#destroy();
          },
        },
      }),
    );
  }

  hideDeleteButton() {
    this.deleteButtonTarget.setAttribute("hidden", "");
  }

  showDeleteButton() {
    this.deleteButtonTarget.removeAttribute("hidden");
  }

  updateTitle() {
    this.titleTarget.innerText = this.title;
  }

  updateDeleteButtonLabel() {
    this.deleteButtonTarget.setAttribute('aria-label', `${this.deleteLabelValue} ${this.title}`);
  }

  updateDestinationLabel() {
    this.destinationTarget.setAttribute(
      "aria-label",
      `${this.destinationLabelValue} ${this.title}`,
    );
  }

  updateFieldLabelsForExpressions() {
    this.expressionTargets.forEach((element) => {
      element.expressionController.updateLabels();
    });
  }

  #destroy() {
    this.conditionalsStatusOutlet.update(`${this.title} removed`);
    this.element.remove();
  }
}
