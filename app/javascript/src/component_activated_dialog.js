/**
 * Activated Dialog Component
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

const DialogActivator = require('./component_dialog_activator');
const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const safelyActivateFunction = utilities.safelyActivateFunction;


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 * config.classes["ui-activator"]  will put the value in activator classes value.
 * config.onOk takes a function to run when 'Ok' button is activated.
 * config.onCancel takes a function to run when 'Cancel' button is activated.
 * config.onClose takes a function to run after dialog is closed.
 **/
class ActivatedDialog {
  constructor($node, config) {
    var conf = mergeObjects({
      $activator: $(),
      $target: $node
    }, config);

    var activator = new DialogActivator(conf.$activator, {
      dialog: this,
      activatorText: conf.activatorText,
      classes: conf.classes["ui-activator"],
      $target: $node
    });

    var buttons = {};

    // Make sure classes is an object even if nothing passed.
    conf.classes = mergeObjects({}, config.classes);

    buttons[conf.okText] = () => {
      safelyActivateFunction(this._config.onOk);
    }

    buttons[conf.cancelText] = () => {
      safelyActivateFunction(this._config.onCancel);
      this.close();
    }

    $node.data("instance", this);
    $node.dialog({
      autoOpen: conf.autoOpen || false,
      buttons: buttons,
      classes: conf.classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
      close: conf.onClose
    });

    this._config = conf;
    this.$container = $node.parents(".ui-dialog").addClass(" ActivatedDialog");
    this.$node = $node;
    this.activator = activator;
  }

  open() {
    this.$node.dialog("open");
  }

  close() {
    this.$node.dialog("close");
  }
}


// Make available for importing.
module.exports = ActivatedDialog;

