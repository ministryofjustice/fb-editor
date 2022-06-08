/**
 * Publish Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the Publish FB Editor view.
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


const DefaultController = require('./controller_default');
const DialogForm = require('./component_dialog_validation');

class PublishController extends DefaultController {
  constructor(app) {
    super(app);

    switch(app.page.action) {
      case "create":
        PublishController.create.call(this);
        break;
      case "index":
        PublishController.index.call(this);
        break;
    }
  }
}


/* Setup for the Index action
 **/
PublishController.index = function() {
  var view = this;
  setupPublishForms.call(view);

  // When to show 15 minute message.
  if(view.publishFormTest.firstTimePublish() || view.publishFormProd.firstTimePublish()) {
    view.dialog.content = {
      ok: view.text.dialogs.button_publish,
      heading: view.text.dialogs.heading_publish,
      content: view.text.dialogs.message_publish
    };

    view.dialog.open();
  }
}


/* Set up for the Create action
 **/
PublishController.create = function() {
  var view = this;
  setupPublishForms.call(view);
  view.ready();
}


/* Setup the Publish Form as an enhanced object.
 **/
class PublishForm {
  constructor($node) {
    var $content = $node.find(".govuk-form");
    var $radios = $node.find("input[type=radio]");
    var $submit = $node.find("input[type=submit]");
    var $errors = $node.find(".govuk-error-message");

    new ContentVisibilityController($content, $radios);
    new DialogForm($node, {
      autoOpen: $errors.length ? true : false,
      activator: true,
      activatorText: $submit.val(),
      classes: {
        'activator': "govuk-button fb-govuk-button",
      }
    })

    this.$node = $node;

  }

  firstTimePublish() {
    return this.$node.data("first_publish");
  }
}


/* Show/hide content based on a yes/no type of radio button control.
 * @content (jQuery node) Content area to be shown/hidden
 * @config (Object) Configuration of widget
 *  e.g. {
 *         showActivators: $(elements-that-will-set-content-to-show-on-click),
 *         hideActivators: $(elements-that-will-set-content-to-hide-on-click),
 *         visibleOnLoad: Function || Boolean // Value should be true/false but you can pass a function to return such a value.
 *       }
 **/
class ContentVisibilityController {
  constructor($content, $radios) {
    // Set listener.
    if($radios.length > 0) {
      $radios.eq(0).on("change", this.toggle.bind(this));
      $radios.eq(1).on("change", this.toggle.bind(this));
      this.$content = $content;
      this.$radios = $radios;
      this.toggle();
    }
  }

  toggle() {
    // Set initial state.
    if(this.$radios.last().prop("checked") || this.$radios.last().get(0).checked) {
      this.$content.show();
    }
    else {
      this.$content.hide();
    }
  }
}


// Private

/* Find and setup publish forms
 **/
function setupPublishForms(page) {
  this.publishFormTest = new PublishForm($("#publish-form-dev"));
  this.publishFormProd = new PublishForm($("#publish-form-live"));
}

module.exports = PublishController;
