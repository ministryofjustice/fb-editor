import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['expression']

    initialize() {
        this.connected = false;
    }

    connect() {
        Promise.resolve().then(() => {
            this.connected = true
            this.preventFirstExpressionDeletion()
            this.allowFirstExpressionDeletion()
            this.updateExpressionIndices()
        })
    }

    expressionTargetDisconnected() {
        this.preventFirstExpressionDeletion()
        this.updateExpressionIndices()
    }

    update(event) {
        if (event.detail.additionType != 'expression') return

        Promise.resolve().then(() => {
            this.allowFirstExpressionDeletion();
            this.updateExpressionIndices();
        })
    }


    preventFirstExpressionDeletion() {
        if (this.expressionTargets.length == 1) {
            this.expressionTargets[0].expressionController.hideDeleteButton()
        }
    }

    allowFirstExpressionDeletion() {
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
