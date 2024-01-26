import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static targets = ["question", "content"];
  static values = {
    content: Object,
  };

  static ancestor = "components";

  connect() {
    useControllerName(this);
    useAncestry(this);
  }

  update(event) {
    const orderValue = event.detail.order;

    if (this.hasQuestionTarget) {
      this.updateQuestionData(orderValue);
    }
    if (this.hasContentTarget) {
      this.updateContentConfig(orderValue);
    }

    document.dispatchEvent(
      new CustomEvent("SaveRequired", {
        bubbles: true,
      }),
    );
  }

  updateQuestionData(orderValue) {
    const data = JSON.parse(this.questionTarget.dataset.fbContentData);
    const newData = Object.assign(data, { order: orderValue });
    this.questionTarget.dataset.fbContentData = JSON.stringify(newData);
  }

  updateContentConfig(orderValue) {
    const data = JSON.parse(this.contentTarget.dataset.config);
    const newData = Object.assign(data, { order: orderValue });
    this.contentTarget.dataset.config = JSON.stringify(newData);
  }
}
