import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['title', 'deleteButton']
  static values = {
    title: String
  }

  connect() {
    // Attach a reference to the controller to the element
    this.element[`${this.identifier}Controller`] = this
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

  setTitle(index) {
    this.titleTarget.innerText = `${this.titleValue} ${index}`
  }
}
