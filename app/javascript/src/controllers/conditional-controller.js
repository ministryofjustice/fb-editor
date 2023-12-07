import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['title', 'deleteButton', 'expression']
  static values = {
    index: Number,
    title: String,
    deleteLabel: String
  }

  connect() {
    // Attach a reference to the controller to the element
    this.element[`${this.identifier}Controller`] = this
  }

  indexValueChanged() {
    this.updateTitle()
    this.updateDeleteButtonLabel()
    setTimeout(() => {
      this.updateFieldLabelsForExpressions()
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

  updateFieldLabelsForExpressions() {
    this.expressionTargets.forEach((element) => {
      element.expressionController.updateFieldLabels()
    })
  }
}
