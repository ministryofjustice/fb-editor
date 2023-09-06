import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['deleteButton']

  connect() {
    // Attach a reference to the controller to the element
    this.element[this.identifier] = this
  }

  delete(event) {
    this.element.remove()
  }

  hideDeleteButton(){
    this.deleteButtonTarget.setAttribute('hidden', '')
  }

  showDeleteButton() {
    this.deleteButtonTarget.removeAttribute('hidden')
  }
}
