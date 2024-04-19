import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";

export default class extends Controller {
  static targets = ["propertiesButton"];

  connect() {
    useControllerName(this);

    // GLOBAL ALERT! app is a global object set in partials/_properties.html.erb
    this.labels = app.text.components[this.type];
  }

  propertiesButtonTargetConnected() {
    this.updateLabels();
  }

  /**
   * Focuses the component
   * @param {Event} event
   * 1. This is called after moving the component, if the move was triggered via
   * keyboard, then we want focus to remain on the move button, so return early
   *
   * 2. If the component is editable content, focus is placed directly onto the
   * editable input (as we never leave edit mode)
   *
   * 3. Otherwise focus is placed on the editable heading of the component
   **/
  focus(event) {
    const keyboardEvent = event.detail == 0;
    if (keyboardEvent) return; //[1]

    if (this.isEditableContent) {
      this.element.input.focus(); //[2]
    } else {
      this.element.querySelector(".EditableElement")?.focus(); //[3]
    }
  }

  /**
   *   Updates the data stored on the component
   *   Handles differently depending on component type
   *   @param {Event} event
   **/
  update(event) {
    this.orderValue = event.detail.order;

    this.isEditableContent
      ? this.updateContentConfig()
      : this.updateQuestionData();

    this.updateLabels();
    this.triggerSaveRequired();
  }

  destroy(event) {
    this.triggerSaveRequired();
    this.element.remove();
  }

  updateLabels() {
    if (this.hasPropertiesButtonTarget) {
      this.propertiesButtonTarget.setAttribute(
        "aria-label",
        this.propertiesButtonLabel,
      );
    }
  }

  /**
   * Handles updating the data on a question component
   * @param {Integer} orderValue
   * 1. The data is not stored on the data attribute but within jQuery data()
   * for the EditableComponent instance
   **/
  updateQuestionData() {
    const data = JSON.parse(this.element.dataset.fbContentData);
    const newData = Object.assign(data, { order: this.orderValue });
    const editableInstance = $(this.element).data("instance"); // [1] A reference to the EditableComponent instance

    if (editableInstance) {
      editableInstance.data = newData;
    }
  }

  /**
   * Handles updating the data on an editable content component
   * @param {Integer} orderValue
   * The content component *does* store the data directly in the data attribute
   * so we can just update that directly
   * **/
  updateContentConfig() {
    const data = JSON.parse(this.element.dataset.config);
    const newData = Object.assign(data, { order: this.orderValue });

    this.element.dataset.config = JSON.stringify(newData);
  }

  triggerSaveRequired() {
    this.element.dispatchEvent(
      new CustomEvent("SaveRequired", {
        bubbles: true,
      }),
    );
  }

  get type() {
    return this.element.tagName == "EDITABLE-CONTENT" ? "content" : "component";
  }

  get isEditableContent() {
    return this.type == "content";
  }

  get propertiesButtonLabel() {
    return this.labels.properties.replace("{{index}}", this.orderValue + 1);
  }
}
