import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['conditional']

  initialize() {
    this.connected = false;
  }

  connect() {
    Promise.resolve().then(() => {
      this.connected = true
      this.preventFirstConditionalDeletion();
      this.allowFirstConditionalDeletion();
      this.updateConditionalIndices();
    })
  }

  conditionalTargetDisconnected() {
    this.preventFirstConditionalDeletion();
    this.updateConditionalIndices();
  }

  update(event) {
    if (event.detail.additionType != 'conditional') return

    Promise.resolve().then(() => {
      this.allowFirstConditionalDeletion();
      this.updateConditionalIndices();
    })
  }

  preventFirstConditionalDeletion() {
    if (this.conditionalTargets.length == 1) {
      this.conditionalTargets[0].conditionalController.hideDeleteButton()
    }
  }

  allowFirstConditionalDeletion() {
    if (this.conditionalTargets.length > 1) {
      this.conditionalTargets[0].conditionalController.showDeleteButton()
    }
  }

  updateConditionalIndices() {
    this.conditionalTargets.forEach((conditional, index) => {
      conditional.conditionalController.indexValue = index + 1
    })
  }
}
