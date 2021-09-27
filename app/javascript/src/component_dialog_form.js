/**
 * Dialog Form Component
 * ----------------------------------------------------
 * Description:
 * Enhances jQueryUI Dialog component to make a simple message dialog.
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


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * @$node  (jQuery node) Form element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class FormDialog {
  constructor($node, config) {
    var dialog = this;
    var conf = mergeObjects({
      autoOpen: false,
      classes: "",
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
      cancelText: "cancel",
      removeErrorClasses: "error",
      selectorErrors: ".error",
      selectorAffirmativeButton: "[type='submit']:first",
    }, config);

    var $button = $(conf.selectorAffirmativeButton, $node);
    var $errors = $node.find(conf.selectorErrors);
    var $container;

    $button.hide();
    $button.attr("disabled", true);
    conf.buttons = [
      {
        text: $button.text() || $button.val(),
        click: () => {
          $node.submit();
          dialog.close();
        }
      },
      {
        text: conf.cancelText,
        click: () => {
          dialog.close();
        }
      }
    ];

    $node.dialog(conf);
    $container = $node.parents(".ui-dialog");
    $container.addClass("FormDialog");
    $node.data("instance", this);
    $node.on( "dialogclose", function( event, ui ) {
      $(document).trigger("FormDialogClose");
    });

    this._config = conf;
    this.$container = $container;
    this.$node = $node;
    this.$errors = $errors;
  }

  open() {
    this.$node.dialog("open");
  }

  close() {
    this.$node.dialog("close");
    this.clearErrors();
  }

  clearErrors() {
    this.$errors.parents().removeClass(this._config.removeErrorClasses);
    this.$errors.remove(); // Remove from DOM (includes removing all jQuery data)
    this.$errors = $(); // Make sure nothing is left.
  }
}


// Make available for importing.
module.exports = FormDialog;

