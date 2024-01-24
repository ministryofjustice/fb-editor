import { Controller } from "@hotwired/stimulus";
import {  useControllerName } from "../mixins/use-controller-name"

export default class extends Controller {
  static targets = ["orderableItem"];

  connect() {
    console.log('orderable-items-connected')
    console.log(this.identifier)
    useControllerName(this);
    console.log(this.controllerName)
    // this.element[`${this.identifier}Controller`] = this;
  }

  orderableItemDisconnected() {
    this.updateOrder();
  }

  updateOrder() {
    this.orderableItemTargets.forEach((item, idx) => {
      item.orderableItemController.indexValue = idx;
    });
  }
}
