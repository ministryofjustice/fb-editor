/**
 * Form List Page
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the form list (index page) FB Editor view.
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 **/


const DialogForm = require('./component_dialog_form');
const Dialog = require('./component_dialog');
const DefaultController = require('./controller_default');

class FormListPage extends DefaultController {
  constructor(app) {
    super(app);

    // Create dialog for handling new form input and error reporting.
    new CreateFormDialog($("[data-component='FormCreateDialog']"));
    new CreateTransferDialog($("[data-component='OwnershipTransferDialog']"));

  }
}


class CreateFormDialog {
  constructor($node) {
    var $errors = $node.find( ".govuk-error-message");

    new DialogForm($node, {
      autoOpen: $errors.length ? true : false,
      activator: true,
      activatorText: $node.data("activator-text"),
      classes: {
        "activator": "govuk-button fb-govuk-button"
      },
      onClose: function() {
        $errors.parents().removeClass('error');
        $errors.remove(); // Remove from DOM (includes removing all jQuery data)
        $node.find('.govuk-form-group').removeClass('govuk-form-group--error');
      }
    });
  }
}

class CreateTransferDialog {
  constructor($node) {
    new Dialog($node, {
      autoOpen: true,
      activator: false
    });
  }
}

module.exports = FormListPage;
