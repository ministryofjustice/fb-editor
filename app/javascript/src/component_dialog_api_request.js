/**
* Dialog API Request Component
* ------------------------------------------------------------------------------
* Author: Chris Pymm (chris.pymm@digital.justice.gov.uk)
*
* Description
* ===========
* Provides jQuery UI Dialog around template HTML returned from a server API
* request.
*
* These dialogs are ephemeral - they are created on a successful API request,
* and removed entirely from the DOM once closed.
*
* While it is possible to pass in buttons for jQuery UI to use within the config
* options, it is recommended to have the controlling buttons included within the
* markup in the returned template.
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
*  - buttons (Object[]) [[]]
*    Two element Array containing objects used for passing to the jQueryUI dialog.
*    Do not include config.closeOnClickSelector option when using this one.
*    Use of closeOnClickSelector will cause constructor to ignore config.buttons.
*    Each array element should be of the construction:
*            {
*               text: "This is used for button text",
*               click: function(dialog) {
*                 // an action to run on click that receives the DialogApiRequest
*                 // instance as an argument.
*               }
*            }
*
*  - classes (object) [{}]
*    An object of jQuery ui classes that will be applied to the UI dialog
*    elements
*
*  - closeOnClickSelector (string) ['']
*    jQuery selector string for elements that will close the dialog when
*    clicked. Use this option if you do not pass in buttons.
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

**/

const {
  mergeObjects,
  safelyActivateFunction,
} = require('./utilities');

const DialogActivator = require('./component_dialog_activator');

class DialogApiRequest {
  #className = 'DialogApiRequest';
  #config;
  #state;

  /**
  * @param {string} url - The url to request the template from
  * @param {Object} config - config key/value pairs
  */
  constructor(url, config) {
    this.#config = mergeObjects({
      activator: false,
      autoOpen: true,
      buttons: [],
      classes: {},
      closeOnClickSelector: "",
      onLoad: function(dialog) {},
      onReady: function(dialog) {},
      onOpen: function(dialog) {},
      onClose: function(dialog) {},
    }, config);

    this.#state = "closed";
    this.$node = $(); // Should be overwritten on successful GET
    this.$container = $(); // Should be overwritten on successful GET

    this.#initialize(url);
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
    return this.#state == "open";
  }

  open() {
    const dialog = this;

    this.$node.dialog("open");
    safelyActivateFunction(this.#config.onOpen, dialog);

    queueMicrotask(() => {
      dialog.focus();
    });
  }

  close() {
    const dialog = this;

    this.$node.dialog("close");
    safelyActivateFunction(dialog.#config.onClose, dialog);
  }

  focus() {
    const el = this.$node.find('.govuk-button:not([type="disabled"]):not([data-method="delete"])').eq(0);
    if(el){
      el.focus();
    }
  }

  focusActivator() {
    // Attempt to refocus on original activator
    if(this.activator) {
      this.activator.focus();
    }
  }

  #initialize(url) {
    const dialog = this;

    $.get(url)
    .done( (response) => {
      this.$node = $(response);
      safelyActivateFunction(dialog.#config.onLoad, dialog);

      this.#build();
      this.#enhance();

      if(this.#config.autoOpen) {
        this.open();
      }
    });
  }

  #build() {
    const dialog = this;

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
      open: function() { dialog.#state = "open" },
      close: function() {
        dialog.#state = "closed";
        dialog.focusActivator();
        dialog.#destroy();
      }
    });

    this.$container = dialog.$node.parents(".ui-dialog");
    this.$container.addClass(dialog.#className);
    this.$node.data("instance", dialog);
  }

  #enhance() {
    const dialog = this;

    this.#setupButtons();

    safelyActivateFunction(dialog.#config.onReady, dialog);
  }

  #setupButtons() {
    const dialog = this;

    if(this.#config.closeOnClickSelector) {
      let $buttons = $(this.#config.closeOnClickSelector, dialog.$node);
      $buttons.on("click", function() {
        dialog.close();
      });
    }
    else {
      this.$node.dialog("option", "buttons",
        [
          {
            text: dialog.#config.buttons.length > 0 && dialog.#config.buttons[0].text || "ok",
            click: () => {
              // Attempt to run any passed button.click action.
              if(dialog.#config.buttons.length > 0) {
                safelyActivateFunction(dialog.#config.buttons[0].click, dialog);
              }
              // Make sure the dialog closes
              dialog.close();
            }
          },
          {
            text: dialog.#config.buttons.length > 0 && dialog.#config.buttons[1].text || "cancel",
            click: () => {
              // Attempt to run any passed button.click action.
              if(dialog.#config.buttons.length > 1) {
                safelyActivateFunction(dialog.#config.buttons[1].click, dialog);
              }
              // Make sure the dialog closes
              dialog.close();
            }
          }
        ]
      );
    }
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


module.exports = DialogApiRequest;
