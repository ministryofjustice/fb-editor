import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  update(status) {
    this.element.innerText = status;
  }
}
