import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'question', 'expression', 'errorMessage']
  static classes = [ 'error' ]
  
  connect() {
    console.log("Hello, Stimulus!", this.element)
  }

  getExpression(event) {
    const value = event.currentTarget.value
    const option = event.currentTarget.querySelector(`option[value="${value}"]`)
    const url = event.params.url.replace('--componentId--', value)

    this.clearError()

    if(value == '') {
      this.expressionTarget.setAttribute('hidden', '')
      return
    } 

    if (option.dataset.supportsBranching == 'false') {
      this.expressionTarget.setAttribute('hidden', '')
      this.showError()
      return
    }

    this.expressionTarget.src = url
    this.expressionTarget.removeAttribute('hidden')
  } 

  showError() {
    this.element.classList.add(this.errorClass)
    this.errorMessageTarget.removeAttribute('hidden')
  }

  clearError() {
    this.element.classList.remove(this.errorClass)
    this.errorMessageTarget.setAttribute('hidden', '')
  }
}
