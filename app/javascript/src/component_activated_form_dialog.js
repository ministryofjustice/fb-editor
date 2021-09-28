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


const FormDialog = require('./component_dialog_form');
const DialogActivator = require('./component_dialog_activator');
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
class ActivatedFormDialog extends FormDialog {
  constructor($node, config) {
    var conf = mergeObjects({
      selectorErrors: ".error"
    }, config);

    var $marker = $("<span></span>");
    var $errors = $node.find(conf.selectorErrors);

    $node.before($marker);
    super($node, mergeObjects( config, {
      autoOpen: $errors.length ? true: false,
      cancelText: config.cancelText,
      removeErrorsClasses: conf.removeErrorClasses,
      selectorErrors: conf.selectorErrors
    }));

    var activator = new DialogActivator(conf.$activator, {
      dialog: this,
      activatorText: conf.activatorText,
      classes: conf.classes["ui-activator"],
      $target: $marker
    });

    $marker.remove();

    // Change inherited class name to reflect this Class
    $node.parents(".FormDialog")
      .removeClass("FormDialog")
      .addClass("ActivatedFormDialog");
  }
}


module.exports = ActivatedFormDialog;
