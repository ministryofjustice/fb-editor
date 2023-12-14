import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['title', 'deleteButton', 'expression', 'destination']
  static values = {
    index: Number,
    title: String,
    deleteLabel: String,
    destinationLabel: String,
  }

  connect() {
    // Attach a reference to the controller to the element
    this.element[`${this.identifier}Controller`] = this
  }

  expressionTargetConnected() {
    Promise.resolve().then(() => {
      this.updateFieldLabelsForExpressions()
    })
  }

  indexValueChanged(newValue, oldValue) {
    if (newValue !== oldValue) {
      this.updateTitle()
      this.updateDeleteButtonLabel()
      this.updateDestinationLabel()
      Promise.resolve().then(() => {
        this.updateFieldLabelsForExpressions()
      })
    }
  }

  focusNewExpression(event) {
    const element = event.detail.element
    Promise.resolve().then(() => {
      element.expressionController.questionTarget.focus()
    })
  }

  get title() {
    return `${this.titleValue} ${this.indexValue}`
  }

  delete(event) {
    this.element.remove()
  }

  deleteWithConfirmation(event) {
    document.dispatchEvent(new CustomEvent('ConfirmBranchConditionalRemoval', {
      detail: {
        action: () => { this.element.remove() }
      }
    }))
  }

  hideDeleteButton() {
    this.deleteButtonTarget.setAttribute('hidden', '')
  }

  showDeleteButton() {
    this.deleteButtonTarget.removeAttribute('hidden')
  }

  updateTitle() {
    this.titleTarget.innerText = this.title
  }

  updateDeleteButtonLabel() {
    this.deleteButtonTarget.innerText = `${this.deleteLabelValue} ${this.title}`
  }

  updateDestinationLabel() {
    this.destinationTarget.setAttribute('aria-label', `${this.destinationLabelValue} ${this.title}`)
  }

  updateFieldLabelsForExpressions() {
    this.expressionTargets.forEach((element) => {
      element.expressionController.updateLabels()
    })
  }
}
