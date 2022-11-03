/**
 * Default Controller
 * ----------------------------------------------------
 * Description:
 * Default page controller to be inherited by all specific controllers.
 * Adds standard functionality required for common FB Editor pages.
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 **/


const Dialog = require('./component_dialog');
const SentryLogger=  require('./sentry_logger');
const post = require('./utilities').post;


class DefaultController {
  constructor(app) {
    var view = this;
    var $document = $(document);
    this.type = $(".fb-main-grid-wrapper").data("fb-pagetype");
    this.features = app.features;
    this.sentry = new SentryLogger();
    this.page = app.page;
    this.text = app.text;
    this.dialog = createDialog.call(this);
    this.dialogConfirmation = createDialogConfirmation.call(this);
    this.dialogConfirmationDelete = createDialogConfirmationDelete.call(this);
    this.$document = $document;
    this.$body = $(document.body);
    this.$lastPoint = $(); // Use it to set a focal point in switching between components.
    this.constants = {
      JS_ENHANCEMENT_DONE: "jsdone"
    }

    isolatedMethodDeleteLinks();

    // To support keyboard navigation, try to set focus
    // for tabbing back to last important point.
    $document.on("DialogClose ActivatedDialogClose", function() {
      view.$lastPoint.focus();
      view.$lastPoint = $(); // Reset in case it was never used after any setting.
    });
  }

  /* We have difficulty supporting keyboard tabbing because some components
   * need to interact with others thus, jumping the tab focus around the
   * actual DOM. Some components also have their own keyboard tabbing handling,
   * such as the jQueryUI Dialogs, which makes it even harder to keep track.
   * To compensate, we use a variable on the view called $lastPoint. This is
   * expected to be a jQuery node, set by the last point (node) we want to
   * come back to after a Dialog has closed, for instance (shifting focus back).
   *
   * Register the activator node  as a possible last point for tab focus support.
   **/
  addLastPointHandler($node) {
    var view = this;
    $node.on("keydown", function() {
      view.$lastPoint = $node;
    });
  }

  /* General actions to happen when called by a view that is ready.
   * e.g. Implemented initially for the brief flash of content fix
   *      first required on ServicesController and then shared with
   *      the PublishController.
   *
   * Using this shares code and gives a place for other such actions
   * to happen, if/when they may be discovered.
   **/
  ready() {
    // Reverse the Brief flash of content white screen blocker (see CSS).
    $("#main-content").addClass(this.constants.JS_ENHANCEMENT_DONE);
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
 * Component allows passing a function to it's 'open()' function so that actions
 * can be played out on whether user clicks 'ok' or 'cancel'.
 **/
function createDialogConfirmation() {
  var $template = $("[data-component-template=DialogConfirmation]");
  var $node = $($template.text());
  return new Dialog($node, {
    autoOpen: false,
    classes: {
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
  return new Dialog($node, {
    autoOpen: false,
    classes: {
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
