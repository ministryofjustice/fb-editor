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
      this.updateTitles();
    })
  }

  conditionalTargetDisconnected(element) {
    this.ensureFirstConditionalCannotBeDeleted();
    this.updateTitles();
  }

  conditionalTargetConnected(element) {
    if (!this.connected) return;

    this.allowFirstConditionalToBeDeleted();
    this.updateTitles();
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

  updateTitles() {
    this.conditionalTargets.forEach((conditional, index) => {
      conditional.conditionalController.setTitle(index + 1)
    })
  }
}
