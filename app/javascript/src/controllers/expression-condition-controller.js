import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'operator', 'answer' ]
  static values = {
    matches: Array,
    currentOperator: String
  }

  connect() {
    this.currentOperatorValue = this.operatorTarget.value
  }

  toggleAnswer(event) {
    const value = event.currentTarget.value
    this.currentOperatorValue = value;
  }

  currentOperatorValueChanged(value) {
    if(this.matchesValue.includes(value)) {
      this.answerTarget.setAttribute('disabled', '')
      this.answerTarget.setAttribute('hidden', '')
    } else {
      this.answerTarget.removeAttribute('disabled', '')
      this.answerTarget.removeAttribute('hidden', '')
    }
  }
}
