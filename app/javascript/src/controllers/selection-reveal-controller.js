import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'input', 'reveal' ]
  static values = {
    matches: Array,
    selected: String
  }

  connect() {
    // set initial value and visible/hidden state
    console.log(this.value)
    this.selectedValue = this.value
  }

  get value() {
    switch(this.inputTargetType) {
      case 'select':
        return this.inputTarget.value
        break;
      case 'radio':
      case 'checkbox':
        const checked = this.inputTargets.find( (input) => input.checked )
        return checked.value
        break;
    }
  }

  get inputTargetType() {
    const element = this.inputTargets[0].tagName.toLowerCase()
    if (element == 'select' ) {
      return 'select'
    }

    if(element == 'input') {
      return this.inputTargets[0].getAttribute('type')
    }
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
