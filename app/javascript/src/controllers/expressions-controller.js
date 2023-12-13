import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['expression']

    initialize() {
        this.connected = false;
    }

    connect() {
        Promise.resolve().then(() => {
            this.connected = true
            this.ensureFirstExpressionCannotBeDeleted()
            this.allowFirstExpressionToBeDeleted()
            this.updateExpressionIndices()
        })
    }

    expressionTargetDisconnected() {
        this.ensureFirstExpressionCannotBeDeleted()
        this.updateExpressionIndices()
    }

    expressionTargetConnected() {
        if (!this.connected) return

        this.allowFirstExpressionToBeDeleted();
        this.updateExpressionIndices()
    }

    ensureFirstExpressionCannotBeDeleted() {
        if (this.expressionTargets.length == 1) {
            this.expressionTargets[0].expressionController.hideDeleteButton()
        }
    }

    allowFirstExpressionToBeDeleted() {
        if (this.expressionTargets.length > 1) {
            this.expressionTargets[0].expressionController.showDeleteButton()
        }
    }

    updateExpressionIndices() {
        this.expressionTargets.forEach((element, index) => {
            element.expressionController.indexValue = index + 1
        })
    }
}
