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
  #config;

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
      selectorAffirmativeButton: "[type='submit']:first"
    }, config);

    var nodeName = $node.get(0).nodeName.toLowerCase();
    var $form = nodeName != "form" ? $node.find("form") : $node;
    var $button = $(conf.selectorAffirmativeButton, $node);
    var $errors = $node.find(conf.selectorErrors);

    // Some familiar component setup.
    this.#config = conf;
    $node.data("instance", this);

    // Setup buttons.
    $button.hide();
    $button.attr("disabled", true);
    this.#config.buttons = [
      {
        text: $button.text() || $button.val(),
        click: () => {
          $form.submit();
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

    // Some setup can only happen when jQueryUI dialog is created.
    $node.on("dialogcreate", function(event, ui) {
      var $container = $node.parents(".ui-dialog");
      $container.addClass("FormDialog");
      dialog.$container = $container;
    });

    // Add the jQueryUI dialog functionality.
    $node.dialog(this.#config);

    // Public properties.
    this.$node = $node;
    this.$form = $form;
    this.$errors = $errors;
    // this.$container... see 'dialogcreate' event handler, above.
  }

  // Shortcut to jQuery method doing same thing.
  isOpen() {
    return this.$node.dialog("isOpen");
  }

  open() {
    var $node = this.$node;
    this.$node.dialog("open");
    window.setTimeout(function() {
      // Not great but works.
      // We want the focus put inside dialog as all functionality to trap tabbing is there already.
      // Because we sometimes open dialogs from other components, those other components may (like
      // menus) shift focus from the opening dialog. We need this delay to allow those other events
      // to play out before we try to set focus in the dialog. Delay time is arbitrary but we
      // obviously want it as low as possible to avoid user annoyance. Increase only if have to.
      $node.parent().find("input:not([type='hidden']), button").not(".ui-dialog-titlebar-close").eq(0).focus();
    }, 100);
  }

  close() {
    this.$node.dialog("close");
    this.clearErrors();
  }

  clearErrors() {
    this.$errors.parents().removeClass(this.#config.removeErrorClasses);
    this.$errors.remove(); // Remove from DOM (includes removing all jQuery data)
    this.$errors = $(); // Make sure nothing is left.
  }
}


// Make available for importing.
module.exports = FormDialog;

