/**
 * Form Analytics Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the Settings:Analytics FB Editor view.
 * File and controller name based on Backend controller name.
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


const Expander = require('./component_expander');
const DefaultController = require('./controller_default');


class FormAnalyticsController extends DefaultController {
  constructor(app) {
    super(app);
    switch(app.page.action) {
      case "create":
      case "index":
        this.index();
        break;
    }
  }


  /* VIEW ACTION
   **/
  index() {
    this.#addExpanderEnhancement();
  }


  /* VIEW SETUP
   * 1. Enhance native browser (<details>) functioality with Expander.
   * 2. Make sure the Expanders will be open if Checkbox ticked or an error shows.
   * 3. Allow Checkboxes to also control the Expander components.
   **/
  #addExpanderEnhancement() {
    $(".analytics-environment-configuration").each(function(index) {
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


module.exports = FormAnalyticsController;
