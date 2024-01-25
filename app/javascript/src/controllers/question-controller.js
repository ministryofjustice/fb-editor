import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static values = {
    content: Object,
  };

  static ancestor = "questions";

  connect() {
    useControllerName(this);
    useAncestry(this);
  }

  update(event) {
    const order = event.detail.order;
    this.contentValue = Object.assign(this.contentValue, { order: order });
    document.dispatchEvent(
      new CustomEvent("SaveRequired", {
        bubbles: true,
      }),
    );
  }
}
