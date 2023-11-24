import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['question', 'condition', 'deleteButton', 'label', 'errorMessage']
  static classes = ['error']
  static values = {
    firstLabel: String,
    otherLabel: String
  }

  connect() {
    // Attach a reference to the controller to the element
    this.element[`${this.identifier}Controller`] = this
  }

  getCondition(event) {
    const value = event.currentTarget.value
    const option = event.currentTarget.querySelector(`option[value="${value}"]`)
    const url = event.params.url.replace('--componentId--', value)

    this.clearError()

    if (value == '') {
      this.conditionTarget.setAttribute('hidden', '')
      return
    }

    if (option.dataset.supportsBranching == 'false') {
      this.conditionTarget.setAttribute('hidden', '')
      this.showError('unsupported')
      return
    }

    if (option.dataset.samePage == 'true') {
      this.conditionTarget.setAttribute('hidden', '')
      this.showError('samepage')
      return
    }

    this.conditionTarget.src = url
    this.conditionTarget.reload()
    this.conditionTarget.removeAttribute('hidden')
  }

  delete(event) {
    this.element.remove();
  }

  deleteWithConfirmation() {
    document.dispatchEvent(new CustomEvent('ConfirmBranchExpressionRemoval', {
      detail: {
        action: () => { this.element.remove() }
      }
    }))
  }


  showError(errorType) {
    this.element.classList.add(this.errorClass)
    this.errorMessageTargets.filter((el) => el.dataset.errorType == errorType)
      .forEach((el) => el.removeAttribute('hidden'))
  }

  clearError() {
    this.element.classList.remove(this.errorClass)
    this.errorMessageTargets.forEach((el) => el.setAttribute('hidden', ''))
  }

  hideDeleteButton() {
    this.deleteButtonTarget.setAttribute('hidden', '')
  }

  showDeleteButton() {
    this.deleteButtonTarget.removeAttribute('hidden')
  }

  setLabelText(value) {
    this.labelTarget.innerText = value
  }
}
