import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['template']

  add(event) {
    event.preventDefault();
    console.log(event.params)
    this.templateTarget.insertAdjacentHTML(
      "beforebegin",
      this.templateTarget.innerHTML.replace(
        /__CHILD_INDEX__/g,
        new Date().getTime().toString()
      )
    )
    this.dispatch('fieldsAdded', {
      detail: {
        element: this.templateTarget.previousElementSibling,
        additionType: event.params.type
      }
    })
  }
}
