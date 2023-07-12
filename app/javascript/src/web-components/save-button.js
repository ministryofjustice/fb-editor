class SaveButton extends HTMLButtonElement {
  #enabled;

  static get observedAttributes() {
    return ['save-required']
  }

  constructor() {
    super();
  }

  connectedCallback() {
    this.text = {
      saved: this.dataset.savedLabel || '',
      unsaved: this.dataset.unsavedLabel || '',
      saving: this.dataset.savingLabel || '',
    }
    this.assistiveText = this.dataset.assistiveText
    this.initialized = true;

    setTimeout(() => {
      this.render();
    })
  }

  attributeChangedCallback(attribute, oldValue, newValue) {
    if(!this.initialized) return

    if(attribute == 'save-required' && newValue != oldValue) {
      this.#setState() 
    }
  }

  get describedBy() {
    return this.form.querySelector(`#${this.getAttribute('aria-describedby')}`)
  }

  get preventUnload() {
    return this.hasAttribute('prevent-unload');
  }

  get saveRequired() {
    return this.hasAttribute('save-required');
  }

  set saveRequired(value) {
    this.setAttribute('save-required', value)
  }

  render() {
    this.setAttribute('type', 'submit')
    this.#setState()

    if(this.assistiveText) {
      this.insertAdjacentHTML('afterend', `<span class="sr-only" id="${this.form.id}-save-description"></span>`)
      this.setAttribute('aria-describedby', `${this.form.id}-save-description`)
    }

    this.afterRender();
  }

  afterRender() {
      this.form.addEventListener('input', (event) => this.saveRequired = 'true')
      this.form.addEventListener('submit', (event) => this.#handleSubmit(event))

      this.addEventListener('click', (event) => this.#handleClick(event))
  }

  submit() {
    this.#enabled = true;
    this.form.submit();
  }

  #handleClick(event) {
    if(this.saveRequired) {
      this.innerText = this.text.saving
    } else {
      event.preventDefault();
    }
  }

  #handleSubmit(event) {
    if(this.saveRequired) {
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

  #setState() {
    this.saveRequired ? this.#enable() : this.#disable()
  }

  #enable() {
    this.#enabled = true;
    this.innerText = this.text.unsaved;
    this.setAttribute("aria-disabled", false);

    if(this.describedBy) {
      this.describedBy.innerText = "";
    }

    this.#addBeforeUnloadListener();
  }

  #disable() {
    this.#enabled = false;
    this.innerText = this.text.saved;
    this.setAttribute("aria-disabled", true);

    if(this.describedBy) {
      this.describedBy.innerText = this.assistiveText;
    }

    this.#removeBeforeUnloadListener();
  }

}

module.exports = { SaveButton }

