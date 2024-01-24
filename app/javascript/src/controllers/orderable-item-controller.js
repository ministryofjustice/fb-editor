import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    index: Number,
  };

  connect() {
    console.log("orderable-item-connected");
    console.log(this.identifier);

    this.element[`${this.identifier}Controller`] = this;
    const el = this.element.closest('[data-controller*="orderable-items"]');
    console.log(el);
    Promise.resolve().then(() => {
      this.parentController = el.orderableItemsController;
      console.log(this.parentController);
    });
  }

  increment() {
    if (this.indexValue == this.maxIndexValue) return;
    if (this.nextSibling) this.nextSibling.orderableItemController.indexValue--;
    this.indexValue++;
  }

  decrement() {
    if (this.indexValue == 0) return;
    if (this.previousSibling)
      this.previousSibling.orderableItemController.indexValue++;
    this.indexValue--;
  }

  get previous() {
    if (this.indexValue - 1 < 0) return;
    this.siblings[this.indexValue - 1];
  }

  get next() {
    if (this.indexValue + 1 > this.maxIndexValue) return;
    this.siblings[this.indexValue + 1];
  }

  get siblings() {
    this.parentController.movableItemTargets;
  }

  get maxIndexValue() {
    return this.parentController.orderableItemTargets.length - 1;
  }
}
