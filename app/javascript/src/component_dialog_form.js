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
  #state;

  constructor($node, config) {
    var STATE_OPEN = "open";
    var STATE_CLOSED = "closed"
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
      open: function( event, ui ) {
        dialog.$node.attr("data-state", STATE_OPEN);
        dialog.#state = STATE_OPEN;
      },
      close: function( event, ui ) {
        dialog.$node.attr("data-state", STATE_CLOSED);
        dialog.#state = STATE_CLOSED;
      }
    }, config);

    var nodeName = $node.get(0).nodeName.toLowerCase();
    var $form = nodeName != "form" ? $node.find("form") : $node;
    var $button = $(conf.selectorAffirmativeButton, $node);
    var $errors = $node.find(conf.selectorErrors);
    var $container;

    $button.hide();
    $button.attr("disabled", true);
    conf.buttons = [
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

    this.#state = STATE_CLOSED;
    $node.attr("data-state", STATE_CLOSED);
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
    this.$form = $form;
    this.$errors = $errors;
  }

  get state() {
    return this.#state;
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
    this.$errors.parents().removeClass(this._config.removeErrorClasses);
    this.$errors.remove(); // Remove from DOM (includes removing all jQuery data)
    this.$errors = $(); // Make sure nothing is left.
  }
}


// Make available for importing.
module.exports = FormDialog;

