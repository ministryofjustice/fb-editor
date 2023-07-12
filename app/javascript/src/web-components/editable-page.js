class EditablePage extends HTMLElement {
  #submitEnabled;

  constructor() {
    super();
  }

  connectedCallback() {
    this.formSelector = this.getAttribute('form-selector') || 'form';
    this.#submitEnabled = this.submittable === 'true'

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

  get assistiveDescription() {
    if(!this.button) return

    return this.form.querySelector(`#${this.button.getAttribute('aria-describedby')}`)
  }

  get preventUnload() {
    return this.hasAttribute('prevent-unload');
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
    this.submittedLabel = this.getAttribute('submitted-label')
    this.unsubmittedLabel = this.getAttribute('unsubmitted-label')
    this.submittingLabel = this.getAttribute('submitting-label')
    this.assistiveDescriptionText = this.getAttribute('assistive-description')
    
    this.button.insertAdjacentHTML('afterend', `<span class="sr-only" id="${this.form.id}-save-description"></span>`)
    this.button.setAttribute('aria-describedby', `${this.form.id}-save-description`)
    
    this.afterRender();
  }

  afterRender() {
    if(this.form && this.button && this.assistiveDescription) {
      this.submittable = false;

      this.form.addEventListener('input', (event) => this.submittable = true)
      this.form.addEventListener('submit', (event) => this.#handleSubmit(event))
      this.button.addEventListener('click', (event) => this.#handleClick(event))
    }
  }

  submit() {
    this.#submitEnabled = true;
    this.form.submit();
  }

  #handleClick(event) {
    if(this.submittable) {
      this.#setButtonText(this.submittingLabel)
    } else {
      event.preventDefault();
    }
  }

  #handleSubmit(event) {
    if(this.submittable) {
      this.#removeBeforeUnloadListener();
    } else {
      event.preventDefault();
    }
  }

  #beforeUnloadListener(event) {
    event.preventDefault();
    return event.returnValue = 'Changes you have made will not be submitted';
  }

  #addBeforeUnloadListener() {
    if(this.preventUnload) {
      window.addEventListener('beforeunload', this.#beforeUnloadListener, {capture: true});
    }
  }

  #removeBeforeUnloadListener() {  
    if(this.preventUnload) {
      window.removeEventListener('beforeunload', this.#beforeUnloadListener, {capture: true});
    }
  }

  #enable() {
    this.#submitEnabled = true;

    this.#setButtonText(this.unsubmittedLabel)
    this.button.setAttribute("aria-disabled", false);
    this.assistiveDescription.innerText = "";

    this.#addBeforeUnloadListener();
  }

  #disable() {
    this.#submitEnabled = false;

    this.#setButtonText(this.submittedLabel)
    this.button.setAttribute("aria-disabled", true);
    this.assistiveDescription.innerText = this.assistiveDescriptionText;

    this.#removeBeforeUnloadListener();
  }

  #setButtonText(text) {
    if(this.button.matches('button[type="submit"]')) {
      this.button.innerText = text;
    } 
    else if(this.$button.matches('input[type="submit"]')) {
      this.button.setAttribute('value', text);
    }
  }
}

module.exports = { EditablePage }
