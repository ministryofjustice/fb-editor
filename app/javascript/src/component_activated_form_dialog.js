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
 * @config (Object) Configurable key/value pairs
 *                  - activatorText       (String)   Used for generated activator element text (when no $activator specified).
 *                  - $activator          (jQuery node) Element to use/enhance as the required DialogActivator.
 *                  - autoOpen            (Bootlean) Value will immediately open dialog on creation, or not.
 *                  - cancelText          (String)   Used for cancel button text.
 *                  - classes             (String)   Added to component for extra CSS hooks.
 *                  - removeErrorClasses  (String)   Space separated CSS classnames to remove/revert error style.
 *                  - selectorErrors      (String)   jQuery selector used to find errors within the $node.
 **/
class ActivatedFormDialog extends FormDialog {
  constructor($node, config) {
    var conf = mergeObjects({
      classes: {},
      selectorErrors: ".error"
    }, config);

    var $marker = $("<span></span>");
    var $errors = $node.find(conf.selectorErrors);

    $node.before($marker);
    super($node, mergeObjects( config, {
      autoOpen: $errors.length ? true: false,
      cancelText: config.cancelText,
      removeErrorClasses: conf.removeErrorClasses,
      selectorErrors: conf.selectorErrors
    }));


    // Change inherited class name to reflect this Class
    $node.parents(".FormDialog")
      .removeClass("FormDialog")
      .addClass("ActivatedFormDialog");

    // Create and/or add an Activator
    this.activator = new DialogActivator(conf.$activator, {
      dialog: this,
      text: conf.activatorText,
      classes: conf.classes["ui-activator"],
      $target: $marker
    });

    $marker.remove();
  }
}


module.exports = ActivatedFormDialog;
