/**
 * Submit Handler 
 * -----------------------------------------------------------------------------
 * Description:
 * A wrapper for a form that adds enhancements to the submit behaviour:
 *  - Accessibly disables the submit button when there are no changes to save
 *  - Updates the submit button text to match the current state
 *  - If the button has an aria-describedby attribute it will update this element to explain the
 *  disabled state of the button to AT users
 *  - Optionally provides window.unload protections to prevent changes being
 *  lost
 *
 * Configuration:
 * The constructor accepts a config object with the following properties:
*  - text (object) text strings of the button labels  for the three states of
*  the button: submitted, unsubmitted and submitting.
*  - buttonSelector (string) jQuery selector for the forms button
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
      preventUnload: false,
    }, config);
    
    this.$form = $form;
    this.$button = this.$form.find(this.#config.buttonSelector);
    this.$buttonDescription = this.$form.find('#'+this.$button.attr('aria-describedby'));
    
    this.#submitEnabled = true;

    this.$form.on('submit', (event) => this.#handleSubmit(event));
    this.$button.on('click', (event) => this.#handleClick(event));
  }

  get submittable() {
    return this.#submitEnabled;
  }

  /*
  * Toggle the state.  
  * Set submittable = true to enable the submit button and prevent window unloading (if configured) 
  * @param value (boolean)  
 */
  set submittable(value) {
    if(value) { 
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
    if(this.submittable) {
      this.#setButtonText(this.#config.text.submitting)
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
    if(this.$button.is('button[type="submit"]')) {
      this.$button.text(text);
    } 
    else if(this.$button.is('input[type="submit"]')) {
      this.$button.val(text);
    }
  }
}

module.exports = SubmitHandler;
