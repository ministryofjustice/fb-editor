import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static values = {
    order: Number,
  };
  static ancestor = "orderable-items";

  connect() {
    useControllerName(this);
    useAncestry(this);
  }

  disconnect() {
    this.orderableItemsController.removeChild(this);
    this.orderableItemsController.reorder();
  }

  orderValueChanged(newValue, oldValue) {
    if (newValue != oldValue)
      this.dispatch("orderUpdated", { detail: { order: newValue } });
  }
}
