import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets =  [ 'expression' ]

  initialize() {
    this.connected = false;
  }

  connect() {
    Promise.resolve().then(() => {
      this.connected = true
      this.ensureFirstExpressionCannotBeDeleted()
      this.allowFirstExpressionToBeDeleted()
      this.setExpressionLabels()
    })
  }

  expressionTargetDisconnected(element) {
    this.ensureFirstExpressionCannotBeDeleted()
    this.setExpressionLabels()
  }
  
  expressionTargetConnected(element) {
    if (!this.connected) return

    this.allowFirstExpressionToBeDeleted();
    this.setExpressionLabels()
  }

  ensureFirstExpressionCannotBeDeleted() {
    if(this.expressionTargets.length == 1) {
      this.expressionTargets[0].expressionController.hideDeleteButton()
    }
  }

  allowFirstExpressionToBeDeleted() {
    if(this.expressionTargets.length > 1) {
      this.expressionTargets[0].expressionController.showDeleteButton() 
    }
  }

  setExpressionLabels(element) {
    this.expressionTargets.forEach( (element, index) => {
      if( index == 0) {
       element.expressionController.setLabelText(element.expressionController.firstLabelValue)  
      } else {
        element.expressionController.setLabelText(element.expressionController.otherLabelValue)  
      }
    });
  }
}
