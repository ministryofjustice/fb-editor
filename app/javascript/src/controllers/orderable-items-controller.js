import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static targets = ["orderableItem"];
  static children = "orderable-item";

  connect() {
    useControllerName(this);
    useAncestry(this);
  }

  /**
   * When an item is disconnected we need to update the order of all items
   **/
  orderableItemTargetDisconnected() {
    this.reorder();
  }

  reorder() {
    this.orderableItemTargets.forEach((element, idx) => {
      element.orderableItemController.orderValue = idx;
    });
  }
}
