/**
 * Default Page
 * ----------------------------------------------------
 * Description:
 * Adds standard functionality required for common FB Editor pages.
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const Dialog = require('./component_dialog');
const DialogConfirmation = require('./component_dialog_confirmation');
const post = require('./utilities').post;


class DefaultController {
  constructor(app) {
    this.type = $(".fb-main-grid-wrapper").data("fb-pagetype");
    this.page = app.page;
    this.text = app.text;
    this.dialog = createDialog.call(this);
    this.dialogConfirmation = createDialogConfirmation.call(this);
    this.dialogConfirmationDelete = createDialogConfirmationDelete.call(this);
    this.$document = $(document);
    this.$body = $(document.body);

    isolatedMethodDeleteLinks();
  }
}


/* Create standard Dialog component with single 'ok' type button.
 **/ 
function createDialog() {
  var $template = $("[data-component-template=Dialog]");
  var $node = $($template.text());
  return new Dialog($node, {
    autoOpen: false,
    okText: $template.data("text-ok"),
    classes: {
      "ui-dialog": $template.data("classes")
    }
  });
}


/* Create standard Dialog Confirmation component with 'ok' and 'cancel' type buttons.
 * Component allows passing a function to it's 'confirm()' function so that actions
 * can be played out on whether user clicks 'ok' or 'cancel'.
 **/
function createDialogConfirmation() {
  var $template = $("[data-component-template=DialogConfirmation]");
  var $node = $($template.text());
  return new DialogConfirmation($node, {
    autoOpen: false,
    cancelText: $template.data("text-cancel"),
    okText: $template.data("text-ok"),
    classes: {
      "ui-activator": "govuk-button fb-govuk-button",
      "ui-button": "govuk-button",
      "ui-dialog": $template.data("classes")
    }
  });
}


/* Dialog Confirmation Delete is simply a Dialog Confirmation with a different
 * class name (dialog-confirmation-delete) added to meet style requirements
 * of the 'delete' button.
 **/
function createDialogConfirmationDelete() {
  var $template = $("[data-component-template=DialogConfirmationDelete]");
  var $node = $($template.text());
  return new DialogConfirmation($node, {
    autoOpen: false,
    cancelText: $template.data("text-cancel"),
    okText: $template.data("text-ok"),
    classes: {
      "ui-activator": "govuk-button fb-govuk-button",
      "ui-button": "govuk-button",
      "ui-dialog": $template.data("classes")
    }
  });
}

/* Targets the user links in header.
 * Converts links wanting to use method DELETE into a form
 * that will work with Rails (default RailsJS versions messed
 * with other scripts wanting to use e.preventDefault().
 **/
function isolatedMethodDeleteLinks() {
  $("header [data-method=delete]").on("click", function(e) {
    e.preventDefault();
    post(this.href, { _method: "delete" });
  });
}


module.exports = DefaultController;
