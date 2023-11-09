/* Due to limitations in using the GDS templates, we cannot
 * add appropriate HTML attributes to relevant elements in
 * both radio and checkbox hints. This is a workaround to
 * add them, so fixes missing default text without affecting
 * the current method of finding them view fb-default-text
 * attribute.
 **/
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    empty: String,
  }
  static classes = ["hint"]

  connect() {
    this.addDataAttributes()
  }

  addDataAttributes() {
    const hints = this.element.querySelectorAll(`.${this.hintClass}`);
    hints.forEach((hint) => {
      hint.setAttribute('data-fb-default-text', this.emptyValue)
    })
  }
}
