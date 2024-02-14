import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  // Default order set so that the first item (index 0) still dispatches an
  // orderUpdated event when connected.
  static values = {
    order: { type: Number, default: 9999 },
  };
  static ancestor = "orderable-items";

  connect() {
    useControllerName(this);
    useAncestry(this);
  }

  disconnect() {
    this.orderableItemsController.removeChild(this);
  }

  orderValueChanged(newValue, oldValue) {
    if (newValue !== oldValue) {
      requestAnimationFrame(() => {
        this.dispatch("orderUpdated", { detail: { order: newValue } });
      });
    }
  }
}
