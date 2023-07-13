/**
 * A custom element that extends an HTML Button element to accessibly disable 
 * itself according to the state of the form. Can also optionally be configured
 * to add page unload prevention.
 *
 * Minimum markup:
 * <button is="save-button">Label</button>
 *
 * Complete markup
 * <button is="save-button" 
 *         data-assistive-text="No changes to save"
 *         data-saved-label="Saved"
 *         data-unsaved-label="Save"
 *         data-saving-label="Saving..."
 *         save-required
 *         prevent-unload>
 *    Save
 * </button>
 *
 * Attributes:
 * prevent-unload - adds page unload protection.  If there are changes to save, 
 *                  attempting to leave the page will cause a browser prompt.
 *
 * save-required - controls the state of the button.  If present, the button
 *                 will be enabled, displaying the 'unsaved' label.  If this
 *                 attribute is not present, the button will be accessibly
 *                 disabled using aria-disabled, and the `aria-describedby`
 *                 attribute will contain the assistive text to explain the
 *                 disabled state.
 *
 * The main operation of the component is by attaching an event to the `input`
 * event of the form associated with the button. On input, the save-required
 * attribute is set on the button, enabling it and cimmunicating to the user
 * that there are changes to be saved.
 *
 **/

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
    };
    this.assistiveText = this.dataset.assistiveText;
    this.initialized = true;

    setTimeout(() => {
      this.render();
    })
  }

  attributeChangedCallback(attribute, oldValue, newValue) {
    // In some cases this callback can be called before connectedCallback which
    // would fail without this guard
    if(!this.initialized) return;
    if(newValue == oldValue) return;

    if(attribute == 'save-required') {
      this.#setState();
    }
  }

  get describedBy() {
    return this.form.querySelector(`#${this.getAttribute('aria-describedby')}`);
  }

  get preventUnload() {
    return this.hasAttribute('prevent-unload');
  }

  get saveRequired() {
    return this.hasAttribute('save-required');
  }

  set saveRequired(value) {
    switch(value) {
      case '':
      case 'true':
      case true:
        this.setAttribute('save-required', value);
        break;
      default:
        this.removeAttribute('save-required');
    }
  }

  render() {
    this.setAttribute('type', 'submit'); // ensure type is submit

    if(this.assistiveText) {
      this.insertAdjacentHTML('afterend', `<span class="sr-only" id="${this.form.id}-save-description"></span>`);
      this.setAttribute('aria-describedby', `${this.form.id}-save-description`);
    }

    this.#setState();
    this.afterRender();
  }

  afterRender() {
      this.form.addEventListener('input', (event) => this.saveRequired = 'true');
      this.form.addEventListener('submit', (event) => this.#handleSubmit(event));

      this.addEventListener('click', (event) => this.#handleClick(event));
  }

  // Enables programatically submitting the form, regardless of the state of the
  // button, and bypassing unload prevention.
  submit() {
    this.#enabled = true;
    this.#removeBeforeUnloadListener();
    this.form.submit(); // Does not raise a `submit` event
  }

  #handleClick(event) {
    if(this.saveRequired) {
      this.innerText = this.text.saving;
    } else {
      event.preventDefault();
    }
  }

  #handleSubmit(event) {
    if(this.#enabled) {
      this.#removeBeforeUnloadListener();
    } else {
      event.preventDefault();
      event.stopImmediatePropagation();
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
    this.saveRequired ? this.#enable() : this.#disable();
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

