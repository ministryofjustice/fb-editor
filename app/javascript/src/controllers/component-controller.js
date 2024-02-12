import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";

export default class extends Controller {
  static values = {
    content: Object,
  };

  get isEditableContent() {
    return this.element.tagName == "EDITABLE-CONTENT";
  }

  connect() {
    useControllerName(this);

    this.saveRequiredEvent = new CustomEvent("SaveRequired", {
      bubbles: true,
    });
  }

  focus(event) {
    const keyboardEvent = event.detail == 0;
    if (keyboardEvent) return;

    if (this.isEditableContent) {
      this.element.input.focus();
    } else {
      this.element.querySelector(".EditableElement")?.focus();
    }
  }

  update(event) {
    const orderValue = event.detail.order;

    this.isEditableContent
      ? this.updateContentConfig(orderValue)
      : this.updateQuestionData(orderValue);

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
    const data = JSON.parse(this.element.dataset.config);
    const newData = Object.assign(data, { order: orderValue });

    this.element.dataset.config = JSON.stringify(newData);
  }
}
