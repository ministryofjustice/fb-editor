/**
 * Dialog API Request Component
 * ----------------------------------------------------
 * Description:
 * Expects response content from an API request, which it can wrap in a Dialog effect.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

const {
  mergeObjects,
  safelyActivateFunction,
} = require('./utilities');

const DialogActivator = require('./component_dialog_activator');

/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 *
 * @url    (URL) API request that gets the HTML used to populate the dialog.
 * @config (Object) Configurable key/value pairs.
 *
 * {
 *   activator: HTML node that activated the initial request and resulting dialog
 *
 *   build: A function that will run just before the dialog is created.
 *          This function is passed the API response HTML wrapped in a jQuery object.
 *
 *   buttons: Two element Array containing objects used for passing to the jQueryUI dialog.
 *
 *            Do not include config.closeOnClickSelector option when using this one.
 *            User of closeOnClickSelector will cause constructor to bypass config.buttons.
 *
 *            Each array element should be of the construction:
 *            {
 *               text: "This is used for button text",
 *               click: function(dialog) {
 *                 // an action to run on click that receives the DialogApiRequest instance as an argument.
 *               }
 *            }
 *
 *   closeOnClickSelector: jQuery selector to find elements that will close the dialog on their click event.
 *                         You need this option if you don't pass in any buttons (see above) through config.
 *                         This is useful when target elements are in response HTML.
 * }
 **/
class DialogApiRequest {
  #className = 'DialogApiRequest';
  #config;
  #state;

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

  set activator($node) {
    this.#config.activator = $node;
  }

  get state() {
    return this.#state;
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
    const el = this.$node.find('button:not([type="disabled"]):not([data-method="delete"])').eq(0);
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
    
    if(this.activator) {
      this.#createActivator();
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

  #createActivator() {
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
