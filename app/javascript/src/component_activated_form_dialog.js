/**
 * Activated Form Dialog Component
 * ----------------------------------------------------
 * Description:
 * Wraps a form in Activated Dialog effect.
 * Clears errors on close/cancel, if they are shown.
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


const ActivatedDialog = require('./component_activated_dialog');
const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 * config.onOk takes a function to run when 'Ok' button is activated.
 *
 * @$node  (jQuery node) Form element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class ActivatedFormDialog extends ActivatedDialog {
  constructor($node, config) {
    var $errors = $node.find(".govuk-error-message");
    $node.before(config.activator); // We need to move before invoking any jQueryUI dialog.

    super($node, mergeObjects( config, {
      autoOpen: $errors.length ? true: false,
      cancelText: config.cancelText,
      okText: config.activator.val(),
      activator: config.activator,
      onOk: () => {
        this.$node.submit();
      },
      onClose: () => {
        this.clearErrors();
      }
    }));

    // Change inherited class name to reflect this Class
    $node.parents(".ActivatedDialog")
      .removeClass("ActivatedDialog")
      .addClass("ActivatedFormDialog");

    this.$node = $node;
    this.$errors = $errors;
  }

  clearErrors() {
    this.$errors.parents().removeClass("govuk-form-group--error");
    this.$errors.remove(); // Remove from DOM (includes removing all jQuery data)
    this.$errors = $(); // Make sure nothing is left.
  }
}


module.exports = ActivatedFormDialog;
