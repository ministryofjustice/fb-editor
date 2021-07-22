/**
 * Branches Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality for common FB Editor pages.
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


class BranchesController extends DefaultController {
  constructor(app) {
    super(app);

    switch(app.page.action) {
      case "new":
        BranchesController.create.call(this);
    }
  }
}


/* Setup for the create (new) action
 **/
BranchesController.create = function() {
  console.log("BranchesController.create is alive");
}

module.exports = BranchesController;
