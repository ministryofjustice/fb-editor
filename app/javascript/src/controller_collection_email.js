const DefaultController = require('./controller_default');
const Expander = require('./component_expander');

class CollectionEmailController extends DefaultController {
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
    $(".collect-info-environment-config").each(function(index) {
      var $this = $(this);
      var $checkbox = $("input[type=checkbox]", $this);
      var expander = new Expander($("details", $this), {
        auto_open: $(".govuk-form-group--error", $this).length
      });

      $checkbox.on("click", function() {
        if(this.checked && !expander.isOpen()) {
          expander.open();
        }
      });
    });
  }
}

module.exports = CollectionEmailController;
