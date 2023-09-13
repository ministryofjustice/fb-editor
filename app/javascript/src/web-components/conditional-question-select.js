class ConditionalQuestionSelect extends HTMLElement {
  constructor() {
    super()
  }

  connectedCallback() {
    setTimeout( () => {
      this.render();
    })
  }

  render() {
    this.select = this.querySelector('select')
    this.group = this.closest('.govuk-form-group')
    this.errorMessage = this.querySelector('[data-element="conditional-question-select-error"]')

    this.afterRender()
  }

  afterRender() {
    if (this.select) {
      this.addEventListener('htmx:beforeRequest', (event) => {

        const htmxTarget = event.detail.target
        const select = event.target
        const selection = select.value
        const option = select.querySelector(`option[value="${selection}"]`)

        this.clearError();

        if (selection == '') {
          htmxTarget.setAttribute('hidden', '')
          event.preventDefault();
        } 
        
        if (option.dataset.supportsBranching == 'false') {
          htmxTarget.setAttribute('hidden', '')
          this.showError();
          event.preventDefault()
        }


      })

      this.group.addEventListener('htmx:afterSwap', (event) => {
        const htmxTarget = event.detail.target
        htmxTarget.removeAttribute('hidden')
      })
    } 
  }

  clearError() {
    this.group.classList.remove('error')
    this.errorMessage.setAttribute('hidden','')
  }

  showError() {
    this.group.classList.add('error');
    this.errorMessage.removeAttribute('hidden')
  }


}

module.exports = { ConditionalQuestionSelect }
