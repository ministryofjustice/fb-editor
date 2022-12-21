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
const DefaultController = require('./controller_default');
const { CharacterCount } = require('govuk-frontend');

class FormListPage extends DefaultController {
  constructor(app) {
    super(app);

    // Create dialog for handling new form input and error reporting.
    new CreateFormDialog($("[data-component='FormCreateDialog']"));
    var $characterCount = document.querySelector('[data-module="govuk-character-count"]')
    if ($characterCount) {
      new CharacterCount($characterCount).init()
    }
  }
}


class CreateFormDialog {
  constructor($node) {
    var $dialog = $("[data-component='FormCreateDialog']");
    var $errors = $node.find( ".govuk-error-message");

    new DialogForm($dialog, {
      autoOpen: $errors.length ? true : false,
      activator: true,
      activatorText: $node.data("activator-text"),
      classes: {
        "activator": "govuk-button fb-govuk-button"
      },
      onClose: function() {
        $errors.parents().removeClass('error');
        $errors.remove(); // Remove from DOM (includes removing all jQuery data)
        $dialog.find('.govuk-form-group').removeClass('govuk-form-group--error');
      }
    });
  }
}


module.exports = FormListPage;
