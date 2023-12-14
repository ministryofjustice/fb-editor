import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['question', 'condition', 'operator', 'answer', 'deleteButton', 'label', 'fieldsetLabel', 'errorMessage']
    static classes = ['error']
    static values = {
        index: Number,
        title: String,
        firstLabel: String,
        otherLabel: String
    }

    // A reference to the parent conditional stimulus controller
    get conditionalController() {
        return this.element.closest('[data-controller~=conditional]').conditionalController
    }

    // the title attribute for the parent conditional
    // e.g. 'branch'
    get conditionalTitle() {
        return `${this.conditionalController.title.toLowerCase()}`
    }

    // the title for this expression including its index
    // e.g. 'condition 1'
    get title() {
        return `${this.titleValue} ${this.indexValue}`
    }

    connect() {
        // Attach a reference to this controller to the element
        this.element[`${this.identifier}Controller`] = this
    }

    operatorTargetConnected(element) {
        this.updateFieldLabel(element)
    }

    answerTargetConnected(element) {
        this.updateFieldLabel(element)
    }


    indexValueChanged(newValue, oldValue) {
        if (newValue !== oldValue) {
            this.updateLabels()
        }
    }

    getCondition(event) {
        const value = event.currentTarget.value
        const option = event.currentTarget.querySelector(`option[value="${value}"]`)
        const url = event.params.url.replace('--componentId--', value)

        this.clearErrors()

        if (value == '') {
            this.hideCondition()
            return
        }

        if (option.dataset.supportsBranching == 'false') {
            this.hideCondition()
            this.showError('unsupported')
            return
        }

        if (option.dataset.samePage == 'true') {
            this.hideCondition()
            this.showError('samepage')
            return
        }

        this.conditionTarget.src = url
        this.conditionTarget.reload()
        this.showCondition()
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

    hideCondition() {
        this.conditionTarget.setAttribute('hidden', '')
    }

    showCondition() {
        this.conditionTarget.removeAttribute('hidden')
    }

    hideDeleteButton() {
        this.deleteButtonTarget.setAttribute('hidden', '')
    }

    showDeleteButton() {
        this.deleteButtonTarget.removeAttribute('hidden')
    }

    clearErrors() {
        this.element.classList.remove(this.errorClass)
        this.errorMessageTargets.forEach((el) => el.setAttribute('hidden', ''))
    }

    showError(errorType) {
        this.element.classList.add(this.errorClass)
        this.errorMessageTargets.filter((el) => el.dataset.errorType == errorType)
            .forEach((el) => el.removeAttribute('hidden'))
    }

    updateLabels() {
        this.updateLabel()
        this.updateDeleteButtonLabel()
        this.updateFieldLabels()
    }

    updateLabel() {
        this.labelTarget.innerText = this.indexValue == 1 ? this.firstLabelValue : this.otherLabelValue
    }

    updateDeleteButtonLabel() {
        this.deleteButtonTarget.innerText = `${this.conditionalController.deleteLabelValue} ${this.conditionalTitle} ${this.title}`
    }

    updateFieldLabels() {
        if (this.hasQuestionTarget) this.updateFieldLabel(this.questionTarget)
        if (this.hasOperatorTarget) this.updateFieldLabel(this.operatorTarget)
        if (this.hasAnswerTarget) this.updateFieldLabel(this.answerTarget)
    }

    updateFieldLabel(element) {
        console.log(element)
        const currentValue = element.getAttribute('aria-label')
        let newValue = ''
        if (!currentValue.includes('condition')) {
            newValue = `${currentValue} for ${this.conditionalTitle} ${this.title}`
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
        element.setAttribute('aria-label', newValue)
    }
}
