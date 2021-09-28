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
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const ActivatedFormDialog = require('./component_activated_form_dialog');
const DefaultController = require('./controller_default');


class FormListPage extends DefaultController {
  constructor(app) {
    super(app);

    // Create dialog for handling new form input and error reporting.
    new CreateFormDialog($("[data-component='FormCreateDialog']"));
  }
}


class CreateFormDialog {
  constructor($node) {
    var errorMessageSelector = ".govuk-error-message";
    var $errors = $node.find(errorMessageSelector);
    new ActivatedFormDialog($("[data-component='FormCreateDialog']"), {
      autoOpen: $errors.length ? true: false,
      cancelText: $node.data("cancel-text"),
      activatorText: $node.data("activator-text"),
      selectorErrors: errorMessageSelector,
      removeErrorClasses: ".govuk-form-group--error",
      classes: {
        "ui-button": "govuk-button",
        "ui-activator": "govuk-button fb-govuk-button"
      }
    });
  }
}


module.exports = FormListPage;
