const DefaultController = require('./controller_default');
const { meta } = require('./utilities.js');

class FromAddressController extends DefaultController {
  constructor(app) {
    super(app);
    switch(app.page.action) {
      case 'create':
      case 'index':
        this.index();
      break;
    }
  }

  index() {
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
