import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['question', 'condition', 'operator', 'answer', 'deleteButton', 'label', 'errorMessage']
    static classes = ['error']
    static values = {
        index: Number,
        firstLabel: String,
        otherLabel: String
    }

    connect() {
        // Attach a reference to the controller to the element
        this.element[`${this.identifier}Controller`] = this
    }

    indexValueChanged(value, previous) {
        this.updateLabel()
        this.updateFieldLabels()
    }

    operatorTargetConnected() {
        this.updateFieldLabels()
    }

    answerTargetConnected() {
        this.updateFieldLabels()
    }

    get conditionalController() {
        return this.element.closest('[data-controller~=conditional]').conditionalController
    }

    getCondition(event) {
        const value = event.currentTarget.value
        const option = event.currentTarget.querySelector(`option[value="${value}"]`)
        const url = event.params.url.replace('--componentId--', value)

        this.clearError()

        if (value == '') {
            this.conditionTarget.setAttribute('hidden', '')
            return
        }

        if (option.dataset.supportsBranching == 'false') {
            this.conditionTarget.setAttribute('hidden', '')
            this.showError('unsupported')
            return
        }

        if (option.dataset.samePage == 'true') {
            this.conditionTarget.setAttribute('hidden', '')
            this.showError('samepage')
            return
        }

        this.conditionTarget.src = url
        this.conditionTarget.reload()
        this.conditionTarget.removeAttribute('hidden')
    }

    delete() {
        this.element.remove();
    }

    deleteWithConfirmation() {
        document.dispatchEvent(new CustomEvent('ConfirmBranchExpressionRemoval', {
            detail: {
                action: () => { this.element.remove() }
            }
        }))
    }


    showError(errorType) {
        this.element.classList.add(this.errorClass)
        this.errorMessageTargets.filter((el) => el.dataset.errorType == errorType)
            .forEach((el) => el.removeAttribute('hidden'))
    }

    clearError() {
        this.element.classList.remove(this.errorClass)
        this.errorMessageTargets.forEach((el) => el.setAttribute('hidden', ''))
    }

    hideDeleteButton() {
        this.deleteButtonTarget.setAttribute('hidden', '')
    }

    showDeleteButton() {
        this.deleteButtonTarget.removeAttribute('hidden')
    }

    updateLabel() {
        this.labelTarget.innerText = this.indexValue == 1 ? this.firstLabelValue : this.otherLabelValue
    }

    updateFieldLabels() {
        this.updateFieldLabel(this.questionTarget)
        if (this.hasOperatorTarget) {
            this.updateFieldLabel(this.operatorTarget)
        }
        if (this.hasAnswerTarget) {
            this.updateFieldLabel(this.answerTarget)
        }
    }

    updateFieldLabel(field) {
        const currentValue = field.getAttribute('aria-label')
        let newValue = ''
        if (!currentValue.includes('condition')) {
            // We've not updated this before, update the whole string
            newValue = `${currentValue} for branch ${this.conditionalController.indexValue} condition ${this.indexValue}`
        } else {
            // just update the numbers in the string with new values
            const replacements = [this.conditionalController.indexValue, this.indexValue]
            let idx = 0
            newValue = currentValue.replace(/\d+/g, () => {
                const replacement = replacements[idx]
                idx++
                return replacement
            })
        }
        field.setAttribute('aria-label', `${newValue}`)
    }
}
