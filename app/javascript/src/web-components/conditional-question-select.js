class ConditionalQuestionSelect extends HTMLElement {
  constructor() {
    super()
  }

  connectedCallback() {
    setTimeout( () => {
      console.log('connected')
      this.render();
    })
  }

  render() {
    this.select = this.querySelector('select')
    this.group = this.closest('.govuk-form-group')
    this.errorMessage = this.querySelector('[data-element="conditional-question-select-error"]')

    console.log(this.select)
    console.log(this.group)
    console.log(this.errorMessage)

    this.afterRender()

  }

  afterRender() {
    if (this.select) {
      console.log('afterRender')
      this.addEventListener('htmx:beforeRequest', (event) => {

        console.log('before request')
        const htmxTarget = event.detail.target
        const select = event.target
        const selection = select.value
        const option = select.querySelector(`option[value="${selection}"]`)

        this.clearError();

        if (selection == '') {
          console.log("that ones blank!")
          htmxTarget.setAttribute('hidden', '')
          event.preventDefault();
        } 
        
        if (option.dataset.supportsBranching == 'false') {
          console.log("can't choose that one bud")
          htmxTarget.setAttribute('hidden', '')
          this.showError();
          event.preventDefault()
        }
        console.log('request should proceed')


      })

      this.group.addEventListener('htmx:afterSwap', (event) => {
        console.log('afterswap')
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
