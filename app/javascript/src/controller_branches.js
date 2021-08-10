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


const utilities = require('./utilities');
const DefaultController = require('./controller_default');
const Branch = require('./component_branch');
const BRANCH_SELECTOR = ".branch";
const BRANCH_CONDITION_SELECTOR = ".condition";
const BRANCH_DESTINATION_SELECTOR = ".destination";
const BRANCH_OTHERWISE_SELECTOR = "#branch-otherwise";
const BRANCH_QUESTION_SELECTOR = ".question";
const BRANCH_INJECTOR_SELECTOR = "#add-another-branch";


class BranchesController extends DefaultController {
  constructor(app) {
    super(app);
    this.api = app.api;
    this._branches = [];

    switch(app.page.action) {
      case "new":
        BranchesController.create.call(this);
    }

    addMattsButton(); // Dev only while branches is WIP
  }

  // Create a new branch and record in views branches array.
  addBranch($node) {
    this._branches.push(BranchesController.createBranch.call(this, $node));
  }
}


/* Setup for the create (new) action
 **/
BranchesController.create = function() {
  BranchesController.enhanceCurrentBranches.call(this);
  BranchesController.enhanceBranchInjectors.call(this);
}


/* Find and enhance all current branches.
 **/
BranchesController.enhanceCurrentBranches = function() {
  var view = this;
  $(BRANCH_SELECTOR).not(BRANCH_OTHERWISE_SELECTOR).each(function() {
    view.addBranch($(this));
  });
}


/* Find and enhance all elements that can add a new branch.
 **/
BranchesController.enhanceBranchInjectors = function() {
  var view = this;
  $(BRANCH_INJECTOR_SELECTOR).each(function() {
    new BranchInjector($(this), {
      view: view
    });
  });
}


/* Creates a new branch from a passed element and keeps
 * track of number of branches
 **/
BranchesController.createBranch = function($node) {
  return new Branch($node, {
    condition_selector: BRANCH_CONDITION_SELECTOR,
    destination_selector: BRANCH_DESTINATION_SELECTOR,
    question_selector: BRANCH_QUESTION_SELECTOR,
    expression_url: this.api.get_expression,
    attribute_branch_index: "conditional-index",
    attribute_condition_index: "expression-index",
    view: this
  });
}


/* Creates a BranchInjector object from passed $node.
 * BranchInjectors fetch new HTML for a branch that will
 * be added to the DOM and turned into a Branch object.
 **/
class BranchInjector {
  constructor($node, config) {
    var injector = this;
    var conf = utilities.mergeObjects({}, config);
    this.view = conf.view;
    this._config = conf;
    $node.on("click", function(e) {
      e.preventDefault();
      injector.add();
    });
  }

  /* Gets HTML for a new branch from api request
   **/
  add() {
    var view = this.view;
    var branches = this.view._branches;
    var index = branches.length > 0 ? branches[branches.length - 1].index : 0;
    var url = utilities.stringInject(this.view.api.new_conditional, {
      conditional_index: String(index)
    });

    utilities.updateDomByApiRequest(url, {
      target: $(BRANCH_SELECTOR).eq(index),
      type: "after",
      done: function($node) {
        view.addBranch($node);
      }
    });
  }
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
