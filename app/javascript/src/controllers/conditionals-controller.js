import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets =  [ 'conditional' ]

  initialize() {
    this.connected = false;
  }

  connect() {
    Promise.resolve().then(() => {
      this.connected = true
      this.ensureFirstConditionalCannotBeDeleted();
      this.allowFirstConditionalToBeDeleted();
    })
  }

  conditionalTargetDisconnected(element) {
    this.ensureFirstConditionalCannotBeDeleted();
  }

  conditionalTargetConnected(element) {
    if (!this.connected) return;

    this.allowFirstConditionalToBeDeleted();
  }

  ensureFirstConditionalCannotBeDeleted() {
    if(this.conditionalTargets.length == 1) {
      this.conditionalTargets[0].conditional.hideDeleteButton()
    }
  }

  allowFirstConditionalToBeDeleted() {
    if(this.conditionalTargets.length > 1) {
      this.conditionalTargets[0].conditional.showDeleteButton() 
    }
  }
}
