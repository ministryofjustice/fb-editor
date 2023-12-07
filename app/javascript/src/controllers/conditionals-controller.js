import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['conditional']

  initialize() {
    this.connected = false;
  }

  connect() {
    Promise.resolve().then(() => {
      this.connected = true
      this.ensureFirstConditionalCannotBeDeleted();
      this.allowFirstConditionalToBeDeleted();
      this.updateConditionalIndices();
    })
  }

  conditionalTargetDisconnected(element) {
    this.ensureFirstConditionalCannotBeDeleted();
    this.updateConditionalIndices();
  }

  conditionalTargetConnected(element) {
    if (!this.connected) return;

    this.allowFirstConditionalToBeDeleted();
    this.updateConditionalIndices();
  }

  ensureFirstConditionalCannotBeDeleted() {
    if (this.conditionalTargets.length == 1) {
      this.conditionalTargets[0].conditionalController.hideDeleteButton()
    }
  }

  allowFirstConditionalToBeDeleted() {
    if (this.conditionalTargets.length > 1) {
      this.conditionalTargets[0].conditionalController.showDeleteButton()
    }
  }

  updateConditionalIndices() {
    this.conditionalTargets.forEach((conditional, index) => {
      console.log(index)
      conditional.conditionalController.indexValue = index + 1
    })
  }
}
