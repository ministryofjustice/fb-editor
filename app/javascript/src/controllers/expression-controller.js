import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "question",
    "condition",
    "operator",
    "answer",
    "deleteButton",
    "label",
    "fieldsetLabel",
    "errorMessage",
  ];

  static outlets = ["conditionals-status"];

  static classes = ["error"];

  static values = {
    index: Number,
    title: String,
    firstLabel: String,
    otherLabel: String,
  };

  // A reference to the parent conditional stimulus controller
  get conditionalController() {
    return this.element.closest("[data-controller~=conditional]")
      .conditionalController;
  }

  // the title attribute for the parent conditional e.g. 'branch'
  get conditionalTitle() {
    return `${this.conditionalController.title.toLowerCase()}`;
  }

  // the title for this expression including its index e.g. 'condition 1'
  get title() {
    return `${this.titleValue} ${this.indexValue}`;
  }

  connect() {
    // Attach a reference to this controller to the element
    this.element[`${this.identifier}Controller`] = this;
  }

  operatorTargetConnected(element) {
    this.#updateFieldLabel(element);
  }

  answerTargetConnected(element) {
    this.#updateFieldLabel(element);
  }

  indexValueChanged(newValue, oldValue) {
    if (newValue !== oldValue) {
      this.updateLabels();
    }
  }

  getCondition(event) {
    const value = event.currentTarget.value;
    const option = event.currentTarget.querySelector(
      `option[value="${value}"]`,
    );
    const url = event.params.url.replace("--componentId--", value);

    this.clearErrors();

    if (value == "") {
      this.#hide(this.conditionTarget);
      return;
    }

    if (option.dataset.supportsBranching == "false") {
      this.#hide(this.conditionTarget);
      this.showError("unsupported");
      return;
    }

    if (option.dataset.samePage == "true") {
      this.#hide(this.conditionTarget);
      this.showError("samepage");
      return;
    }

    this.conditionTarget.src = url;
    this.conditionTarget.reload();
    this.#show(this.conditionTarget);
  }

  delete() {
    this.#destroy();
  }

  deleteWithConfirmation() {
    document.dispatchEvent(
      new CustomEvent("ConfirmBranchExpressionRemoval", {
        detail: {
          action: () => {
            this.#destroy();
          },
        },
      }),
    );
  }

  hideDeleteButton() {
    this.#hide(this.deleteButtonTarget);
  }

  showDeleteButton() {
    this.#show(this.deleteButtonTarget);
  }

  clearErrors() {
    this.element.classList.remove(this.errorClass);
    this.errorMessageTargets.forEach((el) => this.#hide(el));
  }

  showError(errorType) {
    this.element.classList.add(this.errorClass);
    this.errorMessageTargets
      .filter((el) => el.dataset.errorType == errorType)
      .forEach((el) => this.#show(el));
  }

  updateLabels() {
    this.updateLabel();
    this.updateDeleteButtonLabel();
    this.updateFieldLabels();
  }

  updateLabel() {
    this.labelTarget.innerText =
      this.indexValue == 1 ? this.firstLabelValue : this.otherLabelValue;
  }

  updateDeleteButtonLabel() {
    this.deleteButtonTarget.setAttribute(
      "aria-label",
      `${this.conditionalController.deleteLabelValue} ${this.conditionalTitle} ${this.title}`,
    );
  }

  updateFieldLabels() {
    if (this.hasQuestionTarget) this.#updateFieldLabel(this.questionTarget);
    if (this.hasOperatorTarget) this.#updateFieldLabel(this.operatorTarget);
    if (this.hasAnswerTarget) this.#updateFieldLabel(this.answerTarget);
  }

  #updateFieldLabel(element) {
    const currentValue = element.getAttribute("aria-label");
    let newValue = "";
    if (!currentValue.includes("condition")) {
      newValue = `${currentValue} for ${this.conditionalTitle} ${this.title}`;
    } else {
      // just update the numbers in the string with new values
      const replacements = [
        this.conditionalController.indexValue,
        this.indexValue,
      ];
      let idx = 0;
      newValue = currentValue.replace(/\d+/g, () => {
        const replacement = replacements[idx];
        idx++;
        return replacement;
      });
    }
    element.setAttribute("aria-label", newValue);
  }

  #hide(element) {
    element.setAttribute("hidden", "");
  }

  #show(element) {
    element.removeAttribute("hidden");
  }

  // Due to ordering, we cannot update the status from a disconnected() observer
  #destroy() {
    this.conditionalsStatusOutlet.update(`${this.title} removed`);
    this.element.remove();
  }
}
