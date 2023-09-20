/**
* Dialog Form Component
* ------------------------------------------------------------------------------
* Author: Chris Pymm (chris.pymm@digital.justice.gov.uk)
*
* Description
* ===========
* Provides a jQuery UI dialog around either a provided HTML template node wihtin
* the page, or an HTML teplate recieved via an API request.
*
* This class is effectively a combination of the Dialog and DialogApiRequest
* classes with added functionality to handle forms.
*
* The form within the dialog can either be submitted synchronoously or
* asynchronously.
*
* Configuration
* =============
* Accepts a configuration object with the following properties in the format
* property (type) [default value]:
*
*  - activator ($node | boolean) [false]
*    Either an existing node that will trigger the dialog, or a boolean value
*    indicating whether or not to create an activator
*
*  - autoOpen (boolean) [false]
*    Open the dialog on creation.
*
*  - classes (object) [{}]
*    An object of jQuery ui classes that will be applied to the UI dialog
*    elements
*
*  - closeOnClickSelector (string) ['button[type="button]']
*    jQuery selector string for elements that will close the dialog when
*    clicked.
*
*  - submitOnClickSelector (string) ['button[type="submit"]']
*    jQuery selector string for the button that will submit the form wihtin the
*    dialog when clicked.
*
*  - remote (boolean) [false]
*    Whether the form will submit async or not
*
*  - disableOnSubmit (false|string) [false]
*    Only used when remote is true.  If a string is provided, the submit button
*    will be disabled on submit, and its label set to the value of this option.
*
*  - onOpen (function(dialog))
*    Callable that will be called when the dialog is opened. Recieves the
*    Dialog class instance as an argument
*
*  - onClose (function(dialog))
*    Callable that will be called when the dialog is closed. Recieves the
*    Dialog class instance as an argument
*
*  - onLoad (function(dialog))
*    Callable that will be called when the response from the server is
*    successfully recieved, but before the jQuery dialog is initialized or any
*    enhancements ahve been applied to the repsonse. Recieves the Dialog class
*    instance as an argument
*
*  - onReady (function(dialog))
*    Callable that will be called when the dialog has been instantiated and all
*    event listeners / JS enhancements have been applied. Recieves the
*    Dialog class instance as an argument
*
*  - onError (function(dialog))
*    Callable that will be called if there is an error in submitting the form
*    asynchronously. Recieves the Dialog class instance as an argument
*
*  - onSuccess (function(dialog))
*    Callable that will be called on successful async submission of the form.
*    Recieves the Dialog class instance as an argument
*
*  - beforeSubmit (function(dialog))
*    Callable that will be called on click of the submit button but before
*    dialog.submit() is called.  Allows manipulation of form values / data if
*    required. Recieves the Dialog class instance as an argument
*
**/

const {
mergeObjects,
safelyActivateFunction,
meta
} = require('./utilities');

const DialogActivator = require('./component_dialog_activator');

class DialogForm {
  #className = 'DialogForm';
  #config;
  #remoteSource;
  #state;

  /**
  * @param {string|jQuery} source - Either a url to request html from or jQuery node
  * @param {Object} config - config key/value pairs
  */
  constructor(source, config) {
    this.#config = mergeObjects({
      activator: false,
      autoOpen: false,
      classes: {},
      closeOnClickSelector: 'button[type="button"]',
      submitOnClickSelector: 'button[type="submit"]',
      remote: false,
      requestMethod: 'GET',
      requestData: {},
      disableOnSubmit: '',
      onLoad: function(dialog) {},
      onReady: function(dialog) {},
      beforeSubmit: function(dialog) {},
      onSuccess: function(data, dialog) {},
      onError: function(data, dialog) {},
      onOpen: function(dialog) {},
      onClose: function(dialog) {},
    }, config);

    this.#remoteSource = false;
    this.#state = "closed";
    this.$node = $(); // Should be overwritten once intialised
    this.$container = $(); // Should be overwritten once intialised
    this.$form = $(); // Should be overwritten on successful GET

    this.#initialize(source);
  }

  get activator() {
    return this.#config.activator;
  }

  get state() {
    return this.#state;
  }

  set activator($node) {
    this.#config.activator = $node;
  }

  isOpen() {
    return this.state == "open";
  }

  open() {
    var dialog = this;

    if(this.$node.dialog('instance')) {
      this.$node.dialog("open");
      this.#state = "open";
      safelyActivateFunction(this.#config.onOpen, dialog);

      queueMicrotask(() => {
        dialog.focus();
      });
    }
  }

  close() {
    var dialog = this;
    // Attempt to refocus on original activator
    this.focusActivator();

    if(this.$node.dialog('instance')) {
      this.$node.dialog("close");
      safelyActivateFunction(dialog.#config.onClose, dialog);
      this.#state = "closed";
    }

    if(this.#remoteSource){
      this.#destroy();
    }
  }

  submit() {
    if( this.#config.remote ) {
      this.#submitRemote();
    } else {
      this.$form.submit();
    }
  }

  focus() {
    // If there is an error summary initialize it and it sill be given focus
    // else if there is an invalid input, place focus there
    // else focus on the first input/button that is not hidden or disabled
    const errorSummary = this.$form.get(0)?.querySelector('[data-module="govuk-error-summary"]')
    if (errorSummary) {
      new window.GOVUKFrontend.ErrorSummary(errorSummary).init()
    } 
    else {
      let el = this.$node.parent().find('input[aria-invalid]').get(0);
      if (!el) {
        el = this.$node.parent().find('input:not([type="hidden"], [type="disabled"]), .govuk-button:not([type="disabled"])').not(".ui-dialog-titlebar-close").eq(0);
      }

      if (el){
        el.focus();
      }
    }
  }

  focusActivator() {
    // Attempt to refocus on original activator
    if(this.activator) {
      this.activator.focus();
    }
  }

  /*
  * simply a function alias for better readability / nicer api
  * expected to be called if the dialog html is changed dynamically
  * will re-enhance the html to add the required functionality
  * */
  refresh() {
    this.#enhance();
  }

  #initialize(source) {
    var dialog = this;

    if(typeof source == 'string') {
      this.#remoteSource = true;
      $.ajax(source, this.#requestConfig())
      .done((response) => {
        this.$node = $(response);
        this.#build();
        // Allow a function to be specified in dialog config
        safelyActivateFunction(dialog.#config.onLoad, dialog);
        this.#enhance();
        if(this.#config.autoOpen) {
          this.open();
        }
      })
    } else {
      this.$node = source;

      this.#build();
      this.#enhance();

      if(this.#config.autoOpen) {
        this.open();
      }
    }

  }

  #requestConfig() {
    let config = {
      method: this.#config.requestMethod,
    }
    if(this.#config.requestMethod == 'POST') {
      config.headers = {
        'X-CSRF-Token': meta('csrf-token') 
      }
      config.data = this.#config.requestData
    }

    return config
  }

  #build() {
    var dialog = this;

    // this.activator is true || $node setup a DialogActivator
    if(this.activator) {
      this.#addActivator();
    }
    this.$node.dialog({
      autoOpen: false,
      classes: this.#config.classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
    });

    this.$container = dialog.$node.parents(".ui-dialog");
    this.$container.addClass(dialog.#className);
    this.$node.data("instance", dialog);
  }

  #enhance() {
    var dialog = this;

    this.$form = this.$node.is('form') ? this.$node : this.$node.find('form');

    if(this.#config.closeOnClickSelector) {
      this.#setupCloseButtons();
    }

    if(this.#config.submitOnClickSelector) {
      this.#setupSubmitButton();
    }

    safelyActivateFunction(dialog.#config.onReady, dialog);
  }

  /* add event listeners to configured close buttons */
  #setupCloseButtons() {
    var dialog = this;
    if(this.#config.closeOnClickSelector) {
      let $buttons = $(this.#config.closeOnClickSelector, this.$container);
      $buttons.on("click", function() {
        dialog.close();
      });
    }
  }

  /* add event listeners to configured submit button */
  #setupSubmitButton() {
    var dialog = this;
    let $button = $(this.#config.submitOnClickSelector, this.$container).first();
    $button.on("click", function(e) {
      e.preventDefault();
      if(dialog.#config.remote && dialog.#config.disableOnSubmit) {
        $button.text(dialog.#config.disableOnSubmit);
        $button.attr('disabled', 'disabled');
      }
      safelyActivateFunction(dialog.#config.beforeSubmit, dialog );
      dialog.submit();
    });
  }

  #submitRemote() {
    var dialog = this;

    $.ajax({
      type: 'POST',
      url: dialog.$form.attr('action'),
      data: new FormData(dialog.$form.get(0)),
      processData: false,
      contentType: false,
      success: function(data) {
        safelyActivateFunction(dialog.#config.onSuccess, data, dialog);
        dialog.close();
        if (data['max_files']) {
          $(document).trigger("MaxFilesSave");
        }
      },
      error: function(data) {
        safelyActivateFunction(dialog.#config.onError, data, dialog);
        dialog.focus();
      }
    });
  }

  #destroy() {
    if(this.$node.dialog('instance')) {
      this.$node.dialog('destroy');
    }
    this.$node.remove();
  }

  #addActivator() {
    var $marker = $("<span></span>");

    this.$node.before($marker);
    var activator = new DialogActivator(this.#config.activator, {
      dialog: this,
      text: this.#config.activatorText,
      classes: this.#config.classes?.activator || '',
      $target: $marker
    });

    this.activator = activator.$node;

    $marker.remove();
  }

}


module.exports = DialogForm;
