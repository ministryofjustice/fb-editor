import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'input', 'reveal' ]
  static values = {
    matches: Array,
    selected: String
  }

  connect() {
    this.selectedValue = this.inputTarget.value
  }

  toggle(event) {
    const value = event.currentTarget.value
    this.selectedValue = value;
  }

  selectedValueChanged(value) {
    if(this.matchesValue.includes(value)) {
      this.revealTarget.setAttribute('disabled', '')
      this.revealTarget.setAttribute('hidden', '')
    } else {
      this.revealTarget.removeAttribute('disabled', '')
      this.revealTarget.removeAttribute('hidden', '')
    }
  }
}
