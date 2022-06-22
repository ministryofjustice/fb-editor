/**
 * Dialog Confirmation Component
 * ----------------------------------------------------
 * Description:
 * Enhances jQueryUI Dialog component.
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

const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const safelyActivateFunction = utilities.safelyActivateFunction;
const Dialog = require('./component_dialog');


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 * config.onOk takes a function to run when 'Ok' button is activated.
 * config.onCancel takes a function to run when 'Cancel' button is activated.
 * config.onClose takes a function to run after dialog is closed.
 *
 * @$node  (jQuery node) Element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class DialogConfirmation extends Dialog {
  constructor($node, config) {
    var conf = mergeObjects( {
      // Configurable
      okText: "ok",
      cancelText: "cancel",
      onOk: function() {},
      onCancel: function() {}
    }, config);

    conf = mergeObjects( conf, {
      // Not configurable
      buttons: [
      {
        text: conf.okText,
        click: () => {
          safelyActivateFunction($node.data("instance")._action);
          this.close(true);
        }
      },
      {
        text: conf.cancelText,
        click: () => {
          var instance = $node.data("instance");
          instance.content = instance._defaultText;
          this.close(false);
        }
      }]
    });

    super($node, conf);

    if($node && $node.length) {
      $node.parents(".ui-dialog").removeClass("Dialog");
      $node.parents(".ui-dialog").addClass("DialogConfirmation");
      $node.data("instance", this);
      $node.on( "dialogclose", function( event, ui ) {
        $(document).trigger("DialogConfirmationClose");
      });

      DialogConfirmation.setElements.call(this, $node);
      DialogConfirmation.setDefaultText.call(this, $node);
    }

    this._config = conf;
    this._action = function() {}; // Should be overwritten in open()
    this.$node = $node;
  }

  get content() {
    return this._defaultText;
  }

  set content(text) {
    super.content = text;
    this._elements.cancel.text(text.cancel || this._defaultText.cancel);
  }

  open(text, action) {
    if(arguments.length > 1 && typeof action == "function") {
      this._action = action;
    }
    super.open(text);
  }

  close(value) {
    if(value) {
      this._config.onOk(this);
    }
    else {
      this._config.onCancel(this);
    }
    this.$node.dialog("close");
  }
}

/* Private
 * Finds required elements to populate this._elements property.
 **/
DialogConfirmation.setElements = function($node) {
  var elements = {};
  var $buttons = $node.parents(".DialogConfirmation").find(".ui-dialog-buttonset button");
  $buttons.eq(1).show(); // Reverse inherited state.

  elements.heading = $node.find("[data-node='heading']");
  elements.content = $node.find("[data-node='content']");

  // Added by the jQueryUI widget so harder to get.
  elements.ok = $buttons.eq(0);
  elements.cancel = $buttons.eq(1);
  this._elements = elements;
}

/* Private
 * Finds on-load text to use as default values.
 **/
DialogConfirmation.setDefaultText = function($node) {
  this._defaultText = {
    heading: this._elements.heading.text(),
    content: this._elements.content.text(),
    ok: this._elements.ok.text(),
    cancel: this._elements.cancel.text()
  };
}


// Make available for importing.
module.exports = DialogConfirmation;

