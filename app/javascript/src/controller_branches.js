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
const Branch = require('./component_branch');
const BRANCH_SELECTOR = ".branch";
const BRANCH_CONDITION_SELECTOR = ".condition";
const BRANCH_DESTINATION_SELECTOR = ".destination";


class BranchesController extends DefaultController {
  constructor(app) {
    super(app);

    switch(app.page.action) {
      case "new":
        BranchesController.create.call(this);
    }

    addMattsButton(); // Dev only while branches is WIP
  }
}


/* Setup for the create (new) action
 **/
BranchesController.create = function() {
  BranchesController.enhanceCurrentBranches.call(this);
}


/* Find and enhance all current branches.
 **/
BranchesController.enhanceCurrentBranches = function() {
  $(BRANCH_SELECTOR).each(function() {
    new Branch($(this), {
      condition_selector: BRANCH_CONDITION_SELECTOR,
      destination_selector: BRANCH_DESTINATION_SELECTOR
    });
  });

}
























/* TO BE REMOVED
 * Only here during early stages of development
 * for developer aid and humour value :-)
 **/
function addMattsButton() {
  var $mattsButton = $("<button>Matt's button</button>");
  $mattsButton.css({
    "animation": "blinker 0.5s linear infinite",
    "background-color": "red",
    "color": "white",
    "display": "none",
    "font-size": "30px",
    "font-weight": "bold",
    "padding": "10px",
    "position": "absolute",
    "right": "50px",
    "top": "200px"
  });

  $(document.body).append($mattsButton);
  $("#form-navigation-heading").on("click", function(event) {
    $mattsButton.toggle();
  });

  if(document.cookie.search("colours=on") == 0) {
    $(document.body).addClass("dev-colours-on");
  }

  $mattsButton.on("click", function() {
    if(document.cookie.search("colours=on") == 0) {
      document.cookie = "colours=off";
      $(document.body).removeClass("dev-colours-on");
    }
    else {
      document.cookie = "colours=on";
      $(document.body).addClass("dev-colours-on");
    }
  });
}


module.exports = BranchesController;
