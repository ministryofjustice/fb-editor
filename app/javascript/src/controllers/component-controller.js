import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  // static targets = ["question", "content"];
  static values = {
    content: Object,
  };
  static ancestor = "components";

  connect() {
    useControllerName(this);
    useAncestry(this);

    this.saveRequiredEvent = new CustomEvent("SaveRequired", {
      bubbles: true,
    });
  }

  focus(event) {
    const keyboardEvent = event.detail == 0;
    if (keyboardEvent) return;

    const editable = this.element.querySelector(".EditableElement");
    if (editable) {
      editable.focus();
    }
  }

  update(event) {
    const orderValue = event.detail.order;

    this.updateQuestionData(orderValue);
    // if (this.hasContentTarget) {
    //   this.updateContentConfig(orderValue);
    // }

    this.element.dispatchEvent(this.saveRequiredEvent);
  }

  destroy(event) {
    this.element.dispatchEvent(this.saveRequiredEvent);
    this.element.remove();
  }

  updateQuestionData(orderValue) {
    const data = JSON.parse(this.element.dataset.fbContentData);
    const newData = Object.assign(data, { order: orderValue });
    const editableInstance = $(this.element).data("instance"); // A reference to the EditableComponent instance

    if (editableInstance) {
      editableInstance.data = newData;
    }
  }

  updateContentConfig(orderValue) {
    const data = JSON.parse(this.contentTarget.dataset.config);
    const newData = Object.assign(data, { order: orderValue });
    this.contentTarget.dataset.config = JSON.stringify(newData);
  }
}
