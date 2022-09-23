const { meta } = require('./utilities.js');
const DefaultController = require('./controller_default');
const SubmitHandler = require('./submit_handler');

class FromAddressController extends DefaultController {
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
    const view = this;
    const  $form = $('#edit_from_address_1');

    this.submitHandler = new SubmitHandler($form, {
      text: {
        submitted: view.text.actions.saved,
        unsubmitted: view.text.actions.save,
        submitting: view.text.actions.saving,
        description: view.text.aria.disabled_save_description,
      },
      buttonSelector: '.fb-govuk-button[type="submit"]',
      preventUnload: false,
    });

    // Don't show 'saved' if there are validation errors.
    if(!$form.hasClass('with-errors')) {
      this.submitHandler.submittable = false;
    }

    this.submitHandler.$form.on('change', (event) => { this.submitHandler.submittable = true } );
    this.#enhanceRemoteButtons();
  }

  #enhanceRemoteButtons() {
    $('button[data-remote]').each(function(index) {
      const $button = $(this);
      const token = meta("csrf-token");
      const url = this.dataset.url;
      const method = this.dataset.method || 'get';
      const message = this.dataset.success;

      $button.on('click', (e) => {
        e.preventDefault();
        $.ajax({
          url: url,
          type: method,
          headers: { 'X-CSRF-Token': token },
          success: () => {
            // If it happens too quickly, it feels like it hasn't done anything
            setTimeout( () =>  { $button.parent().find('[role="alert"]').text(message); $button.remove() }, 400 );
          }
        })
      });
    })
  }
}

module.exports = FromAddressController;
