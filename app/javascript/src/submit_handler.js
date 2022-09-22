
const {
  mergeObjects
} = require('./utilities');

class SubmitHandler {
  #config;
  #submitEnabled

  constructor($form, config) {
    this.#config = mergeObjects({
      text: {
        submitted: '',
        unsubmitted: '',
        submitting: '',
      },
      buttonSelector: ':submit',
      buttonDescriptionSelector: '',
      preventUnload: false,
    }, config);
    
    this.$form = $form;
    this.$button = this.$form.find(this.#config.buttonSelector);
    this.text = this.#config.text;
    if(this.#config.buttonDescriptionSelector) {
      this.$buttonDescription = this.$form.find(this.#config.buttonDescriptionSelector);
    }

    this.$form.on('submit', (event) => this.#handleSubmit(event));
    this.$button.on('click', (event) => this.#handleClick(event));
  }

  get required() {
    return this.#submitEnabled;
  }

  set required(required) {
    if(required) { 
      this.#enable();
    } else {
      this.#disable();
    }
  }

  forceSubmit() {
    const currentState = this.#submitEnabled;
    this.#submitEnabled = true;
    this.$form.submit();
    this.#submitEnabled = currentState;
  }

  #handleClick(event) {
    if(this.required) {
      this.#removeBeforeUnloadListener();
      $(event.target).prop("value", this.#config.text.submitting );
    } else {
      event.preventDefault();
    }
  }

  #handleSubmit(event) {
    if(this.required) {
      $(document).trigger('Save');
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
    if(this.#config.preventUnload) {
      window.addEventListener('beforeunload', this.#beforeUnloadListener, {capture: true});
    }
  }

  #removeBeforeUnloadListener() {  
    if(this.#config.preventUnload) {
      window.removeEventListener('beforeunload', this.#beforeUnloadListener, {capture: true});
    }
  }

  #enable() {
    this.#submitEnabled = true;
    this.$button.prop("value", this.#config.text.unsubmitted );
    this.$button.attr("aria-disabled", false);
    if(this.$buttonDescription) {
      this.$buttonDescription.text("");
    }
    this.#addBeforeUnloadListener();
  }

  #disable() {
    this.#submitEnabled = false;
    this.$button.prop("value", this.#config.text.submitted );
    this.$button.attr("aria-disabled", true);
    if(this.$buttonDescription) {
      this.$buttonDescription.text(this.#config.text.description);
    }
    this.#removeBeforeUnloadListener();
  }
}

module.exports = SubmitHandler;
