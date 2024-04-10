/**
* Dialog Component
* ------------------------------------------------------------------------------
* Author: Chris Pymm (chris.pymm@digital.justice.gov.uk)
*
* Description
* ===========
* Wraps a provided jQuery node with jQuery UI Dialog functionality.  The node
* provided should include any ui buttons to confirm / cancel the action as we do
* not use the native jQuery UI dialog buttons.
*
* These dialogs are intended to be used with a static template (always) present
* in the page, that does not contain the text content.
*
* When the dialog is required the open method is called with the desired
* content, which is then injected into the template and the dialog opened and
* shown to the user.
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
*  - closeOnClickSelector (string) [button:not([data-node="confirm"])]
*    jQuery selector string for elements that will close the dialog when
*    clicked.  Should *not* include the confirmation element.
*
*  - confirmOnClickSelector (string) [button[data-node="confirm"]]
*    jQuery selector string for the 'confirmation' action for the dialog.
*    bin
*
*  - onOpen (function(dialog))
*    Callable that will be called when the dialog is opened. Recieves the
*    Dialog class instance as an argument
*
*  - onClose (function(dialog))
*    Callable that will be called when the dialog is closed. Recieves the
*    Dialog class instance as an argument
*
*  - onConfirm (function(dialog))
*    Callable that will be called when the confirm UI button is clicked. Recieves the
*    Dialog class instance as an argument
*
*  - onReady (function(dialog))
*    Callable that will be called when the dialog has been instantiated and all
*    event listeners / JS enhancements have been applied. Recieves the
*    Dialog class instance as an argument
*
* Setters
* =======
* As the dialog is initialised on a template node and reused with different
* injected content for many actions within the app, the following setters are
* provided to override the global config.
*
* content(text)
* Allows the injection of content for the dialog.  Expects an object with the
* following properties:
*  - heading: The dialog heading/title
*  - content: The main dialog content
*  - confirm: The label for the confirm button
*  - cancel: The label for the (optional) cancel button
*
*  onClose(callable)
*  Allows for a custom onClose callback to be provided for a Dialog instance
*
*  onConfirm(callable)
*  Allows for a custom onConfirm callback to be provided for a Dialog instance
*
*  onOpen(callable)
*  Allows for a custom onOpen callback to be provided for a Dialog instance
*
* References
* ==========
*  - jQueryUI Dialog: https://api.jqueryui.com/dialog
**/

const {
  mergeObjects,
  safelyActivateFunction,
} = require('./utilities');

const DialogActivator = require('./component_dialog_activator');

class Dialog {
  #className = 'Dialog';
  #config;
  #defaultText = {};
  #elements = {};
  #state;

  /**
   * @param {jQuery} $node - the HTML template node
   * @param {Object} config - config key/value pairs
   */
  constructor($node, config) {
    this.#config = mergeObjects({
      activator: false,
      autoOpen: false,
      classes: {},
      closeOnClickSelector: 'button:not([data-node="confirm"])',
      confirmOnClickSelector: 'button[data-node="confirm"]',
      onOpen: function(dialog) {},
      onClose: function(dialog) {},
      onConfirm: function(dialog) {},
      onReady: function(dialog) {},
    }, config);

    this.#state = 'closed';
    this.$node = $(); // Should be overwritten once intialised
    this.$container = $(); // Should be overwritten once intialised

    this.#initialize($node);
  }

  get activator() {
    return this.#config.activator;
  }

  get state(){
    return this.#state;
  }

  get content() {
    return this.#elements;
  }

  set activator($node) {
    this.#config.activator = $node;
  }

  set onClose(callable) {
    this.originalOnClose = this.#config.onClose;
    this.#config.onClose = callable;
  }

  set onConfirm(callable) {
    this.originalOnConfirm = this.#config.onConfirm;
    this.#config.onConfirm = callable;
  }

  set onOpen(callable) {
    this.originalOnOpen = this.#config.onOpen;
    this.#config.onOpen = callable;
  }

  set content(text) {
    let content = mergeObjects(this.#defaultText, text)

    this.#elements.heading.text( content.heading );
    this.#elements.content.html( content.content );
    this.#elements.confirm.text( content.confirm );
    this.#elements.cancel.text( content.cancel );
  }

  isOpen() {
    return this.#state == 'open';
  }

  open(text) {
    const dialog = this;

    this.content = text || {};
    this.$node.dialog('open');
    this.#state = "open";

    safelyActivateFunction(this.#config.onOpen, dialog);

    queueMicrotask(() => {
      dialog.focus();
    });
  }

  close(callback) {
    const dialog = this;

    this.focusActivator();

    this.$node.dialog('close');
    this.#state = 'closed';

    safelyActivateFunction(callback || function(){}, dialog);
    safelyActivateFunction(this.#config.onClose, dialog);

    this.#config.onClose = this.originalOnClose || function() {};
    this.#config.onConfirm = this.originalOnConfirm || function() {};
    this.#config.onOpen = this.originalOnOpen || function() {};
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


  #initialize($node) {
    this.$node = $node;

    this.#build();
    this.#enhance();

    if( this.#config.autoOpen ) {
      this.open();
    }
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
    this.$container.attr("aria-modal", true);
    this.$container.addClass(dialog.#className);
    this.$node.data("instance", dialog);
  }

  #enhance() {
    const dialog = this;
    const $content = $('[data-node="content"]', $content);

    this.#setElements();
    this.#setDefaultText();

    this.$node.find('h3').attr('id', 'dialog-title')
    this.$container.attr('aria-labelledby', 'dialog-title')
    if ($content.length) {
      $content.attr("id", "dialog-content");
      this.$container.attr("aria-describedby", "dialog-content");
    }

    if(this.#config.closeOnClickSelector) {
      this.#setupCloseButtons();
    }

    if(this.#config.confirmOnClickSelector) {
      this.#setupConfirmButton();
    }

    safelyActivateFunction(dialog.#config.onReady, dialog);
  }

  #setElements() {
    this.#elements = {
      heading: this.$node.find("[data-node='heading']"),
      content: this.$node.find("[data-node='content']"),
      confirm: this.$node.find("[data-node='confirm']"),
      cancel: this.$node.find("[data-node='cancel']"),
    }
  }

  #setDefaultText() {
    this.#defaultText = {
      heading: this.#elements.heading.text(),
      content: this.#elements.content.text(),
      confirm: this.#elements.confirm.text(),
      cancel: this.#elements.cancel.text(),
    }
  }

  /* Add event listeners to configured close buttons */
  #setupCloseButtons() {
    const dialog = this;

    if(this.#config.closeOnClickSelector) {
      let $buttons = $(this.#config.closeOnClickSelector, this.$container);
      $buttons.on("click", function() {
        dialog.close();
      });
    }
  }

  #setupConfirmButton() {
    const dialog = this;
    const $button = $(this.#config.confirmOnClickSelector, this.$container).first();
    $button.on("click", function(e) {
      e.preventDefault();
      dialog.close(dialog.#config.onConfirm);
    });
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

module.exports = Dialog;
