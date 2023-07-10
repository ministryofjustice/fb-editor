class EditablePage extends HTMLElement {

  constructor() {
    super();
  }

  connectedCallback() {
    const this.formSelector = this.getAttribute('form-selector');
    const this.#submitEnabled = this.submittable === 'true'

    setTimeout(() => {
      this.render();
    })
  }

  get form() {
    return this.querySelector(this.formSelector)
  }

  get button() {
    if(!this.form) return

    return this.form.querySelector('[type="submit"]')
  }

  get buttonDescription() {
    if(!this.button) return

    return this.form.querySelctor(`#${this.button.getAttribute('aria-describedby')}`)
  }

  get submittable() {
    return this.#submitEnabled
  }

  set submittable(value) {
    if(value) { 
      this.#enable();
    } else {
      this.#disable();
    }

  }

  render() {
    this.afterRender();
  }

  afterRender() {
    if(this.form && this.button && this.buttonDescription) {
      this.form.addEventListener('submit', (event) => this.#handleSubmit(event))
      this.button.addEventListener('click', (event) => this.#handleClick(event))
    }
  }

  submit() {
    this.#submitEnabled = true;
    this.form.submit();
  }

  #enable() {
    this.#submitEnabled = true;

    this.#setButtonText(this.#config.text.unsubmitted)
    this.button.attr("aria-disabled", false);
    this.buttonDescription.text("");

    this.#addBeforeUnloadListener();

  }

  #disable() {

  }

  #setButtonText(text) {
    if(this.button.matches('button[type="submit"]')) {
      this.button.innerText(text);
    } 
    else if(this.$button.matches('input[type="submit"]')) {
      this.button.setAttribute('value', text);
    }
  }

}
module.exports = { EditablePage }
