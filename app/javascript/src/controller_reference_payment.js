const DefaultController = require('./controller_default');
const Expander = require('./component_expander');

class ReferencePaymentController extends DefaultController {
  constructor(app) {
    super(app);

    switch(app.page.action) {
      case 'create':
      case 'index':
        this.#index();
      break;
    }
  }

  #index() {
    this.#addExpanderEnhancement();
  }

  #addExpanderEnhancement() {
    var $paymentField = $(".fb-payment-field");
    var $revealedInput = $paymentField.find('[data-component="Expander"]');
    var $checkbox = $("input[type=checkbox]", $paymentField);
    new Expander($revealedInput, {
      activator_source: $checkbox,
      auto_open: $checkbox.attr('checked')||$(".govuk-form-group--error", $paymentField).length,
      wrap_content: false,
    });
  }
}

module.exports = ReferencePaymentController;
