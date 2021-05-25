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
 * config.classes["ui-activator"]  will put the value in activator classes value.
 * config.onOk takes a function to run when 'Ok' button is activated.
 * config.onCancel takes a function to run when 'Cancel' button is activated.
 * config.onClose takes a function to run after dialog is closed.
 *
 * @$node  (jQuery node) Element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class DialogConfiguration extends Dialog {
  constructor($node, config) {
    super($node, mergeObjects( config, {
      buttons: [
      {
        text: config.okText,
        click: () => {
          this.save();
          $node.dialog("close");
        }
      },
      {
        text: config.cancelText,
        click: () => {
          var instance = $node.data("instance");
          instance.content = instance._defaultText;
          $node.dialog("close");
        }
      }]
    }));

    if($node && $node.length) {
      $node.parents(".ui-dialog").removeClass("Dialog");
      $node.parents(".ui-dialog").addClass("DialogConfiguration");
      $node.data("instance", this);

      DialogConfiguration.setElements.call(this, $node);
      DialogConfiguration.setDefaultText.call(this, $node);
    }

    this.saveAction = function(){} // Gets overwritten within set content.
  }

  get content() {
    return this._elements.content;
  }

  set content(text) {
    this._elements.content.empty();
    this._elements.content.html(text.content);
  }

  configure(text, action) {
    this.content = text;
    this._saveAction = action;
    this.$node.dialog("open");
  }

  save() {
    safelyActivateFunction(this._saveAction, this.content)
  }
}

/* Private
 * Replace inherited elements with those required for this dialog.
 * Finds required elements to populate this._elements property.
 **/
DialogConfiguration.setElements = function($node) {
  var elements = {};
  var $buttons = $node.parents(".DialogConfiguration").find(".ui-dialog-buttonset button");
  $buttons.eq(1).show(); // Reverse inherited state.

  elements.content = $node.find("[data-node='content']");

  // Added by the jQueryUI widget so harder to get.
  elements.ok = $buttons.eq(0);
  elements.cancel = $buttons.eq(1);
  this._elements = elements;
}

/* Private
 * Replace inherited elements with those required for this dialog.
 * Finds on-load text to use as default values.
 **/
DialogConfiguration.setDefaultText = function($node) {
  this._defaultText = {
    content: "",
    ok: this._elements.ok.text(),
    cancel: this._elements.cancel.text()
  };
}


// Make available for importing.
module.exports = DialogConfiguration;

