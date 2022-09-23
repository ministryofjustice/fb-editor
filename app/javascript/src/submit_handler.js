/**
 * Submit Handler 
 * -----------------------------------------------------------------------------
 * Description:
 * A wrapper for a form that adds enhancements to the submit behaviour:
 *  - Accessibly disables the submit button when there are no changes to save
 *  - Can also update an aria-live button description element to explain the
*  disabled state of the button to AT users
 *  - Updates the submit button text to match the current state
 *  - Optionally provides window.unload protections to prevent changes being
 *  lost
 *
 * Configuration:
 * The constructor accepts a config object with the following properties:
*  - text (object) text strings of the button labels  for the three states of
*  the button: submitted, unsubmitted and submitting.
*  - buttonSelector (string) jQuery selector for the forms button
*  - buttonDescriptionSelector (string) jQuery selector for the buttons
*  accessible description 
*  - preventUnload (boolean) whether or not to enable the window unload event
*  listeners.
**/
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
        description: '',
      },
      buttonSelector: ':submit',
      buttonDescriptionSelector: '',
      preventUnload: false,
    }, config);
    
    this.$form = $form;
    this.$button = this.$form.find(this.#config.buttonSelector);
    this.text = this.#config.text;
    this.$buttonDescription = this.$form.find(this.#config.buttonDescriptionSelector);
    
    this.$form.on('submit', (event) => this.#handleSubmit(event));
    this.$button.on('click', (event) => this.#handleClick(event));
  }

  get required() {
    return this.#submitEnabled;
  }

  /*
  * Toggle the state.  
  * Set required = true to enable the submit button and prevent window unloading (if configured) 
 */
  set required(required) {
    if(required) { 
      this.#enable();
    } else {
      this.#disable();
    }
  }

  /*
  * Provide the ability to programatically submit the form, regardless of the
  * state of the UI button, and without affecting the UI.
  */
  submit() {
    this.#submitEnabled = true;
    this.$form.submit();
  }

  #handleClick(event) {
    if(this.required) {
      this.#setButtonText(this.#config.text.submitting)
    } else {
      event.preventDefault();
    }
  }

  #handleSubmit(event) {
    if(this.required) {
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

    this.#setButtonText(this.#config.text.unsubmitted)
    this.$button.attr("aria-disabled", false);
    this.$buttonDescription.text("");

    this.#addBeforeUnloadListener();
  }

  #disable() {
    this.#submitEnabled = false;

    this.#setButtonText(this.#config.text.submitted)
    this.$button.attr("aria-disabled", true);
    this.$buttonDescription.text(this.#config.text.description);

    this.#removeBeforeUnloadListener();
  }

  #setButtonText(text) {
    if(this.$button.is('button')) {
      this.$button.text(text);
    }

    if(this.$button.is('input')) {
      this.$button.val(text);
    }
  }
}

module.exports = SubmitHandler;
