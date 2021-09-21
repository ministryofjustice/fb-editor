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
const ActivatedMenu = require('./component_activated_menu');
const Branch = require('./component_branch');
const BranchDestination = require('./component_branch_destination');
const BRANCH_SELECTOR = ".branch";
const BRANCH_ANSWER_SELECTOR = ".answer";
const BRANCH_CONDITION_SELECTOR = ".condition";
const BRANCH_REMOVE_SELECTOR = ".branch-remover";
const BRANCH_CONDITION_ADD_SELECTOR = ".condition-injector";
const BRANCH_CONDITION_REMOVE_SELECTOR = ".condition-remover";
const BRANCH_DESTINATION_SELECTOR = ".destination";
const BRANCH_OTHERWISE_SELECTOR = "#branch-otherwise";
const BRANCH_QUESTION_SELECTOR = ".question";
const BRANCH_INJECTOR_SELECTOR = "#add-another-branch";
const BRANCH_ERROR_MESSAGE_SELECTOR = ".govuk-error-message" // Injected messages
const CSS_CLASS_ERRORS = "error govuk-form-group--error" // Not a selector. Space separated list of classes.


class BranchesController extends DefaultController {
  constructor(app) {
    super(app);
    this.api = app.api;

    switch(app.page.action) {
      case "new":
      case "create":
      case "edit":
      case "update":
        this.create();
    }
  }

   /* Setup view for the create (new) action
   **/
  create() {
    var $branches = $(BRANCH_SELECTOR).not(BRANCH_OTHERWISE_SELECTOR);
    var $injectors = $(BRANCH_INJECTOR_SELECTOR);
    var $otherwise = $(BRANCH_OTHERWISE_SELECTOR + " " + BRANCH_DESTINATION_SELECTOR);

    this._branchCount = 0;
    this._branchConditionTemplate = createBranchConditionTemplate($branches.eq(0));

    BranchesController.enhanceCurrentBranches.call(this, $branches);
    BranchesController.enhanceBranchInjectors.call(this, $injectors);
    BranchesController.enhanceBranchOtherwise.call(this, $otherwise);

    // NEXT LINE DEV ONLY: while branches is WIP
    addMattsButton();
  }
}


/* Find and enhance all current branches.
 **/
BranchesController.enhanceCurrentBranches = function($branches) {
  var view = this;
  $branches.each(function(index) {
    var branch = BranchesController.createBranch.call(view, $(this));

    // Remove the delete button to ensure we always have a default
    // branch with one condition.
    if(index == 0) {
      branch.$node.find(".BranchRemover").eq(0).hide();
    }
  });
}


/* Find and enhance all elements that can add a new branch.
 **/
BranchesController.enhanceBranchInjectors = function($injectors) {
  var view = this;
  $injectors.each(function() {
    new BranchInjector($(this), {
      view: view
    });
  });
}


/* Find and enhance 'otherwise' destination with same/similar functionality
 * to destination elmements found within Branch elements.
 **/
BranchesController.enhanceBranchOtherwise = function($otherwise) {
  var view = this;
  $otherwise.each(function() {
    new BranchDestination($(this), {
      css_classes_error: CSS_CLASS_ERRORS,
      selector_error_messsage: BRANCH_ERROR_MESSAGE_SELECTOR,
      view: view
    });
  });
}


/* Find branch menu element and wrap with ActivatedMenu
 * functionality.
 **/
BranchesController.addBranchMenu = function(args) {
  var branch = args[0];
  var $form = branch.$node.parent("form");
  var $ul = branch.$node.find(".component-activated-menu");
  var first = $(".Branch", $form).get(0) == branch.$node.get(0);
  if(!first) {
    new ActivatedMenu($ul, {
      activator_text: "Activator text here",
      container_classname: "SomeClassName",
      container_id: utilities.uniqueString("activated-menu-"),
      menu: {
        position: { my: "left top", at: "right-15 bottom-15" } // Position second-level menu in relation to first.
      }
    });
  }
}


/* Creates a new branch from a passed element and keeps
 * track of number of branches
 **/
BranchesController.createBranch = function($node) {
  var branch = new Branch($node, {
    branch_index: this._branchCount,
    css_classes_error: CSS_CLASS_ERRORS,
    selector_answer: BRANCH_ANSWER_SELECTOR,
    selector_branch_remove: BRANCH_REMOVE_SELECTOR,
    selector_condition: BRANCH_CONDITION_SELECTOR,
    selector_condition_add: BRANCH_CONDITION_ADD_SELECTOR,
    selector_condition_remove: BRANCH_CONDITION_REMOVE_SELECTOR,
    selector_destination: BRANCH_DESTINATION_SELECTOR,
    selector_error_messsage: BRANCH_ERROR_MESSAGE_SELECTOR,
    selector_question: BRANCH_QUESTION_SELECTOR,
    expression_url: this.api.get_expression,
    question_label: this.text.branches.label_question_and,
    template_condition: this._branchConditionTemplate,
    event_on_create: function(branch) {
      BranchesController.addBranchMenu(branch);
    },
    event_question_change: function() {
      if(this.$node.find(".BranchAnswer").length > 0) {
        this.$node.find(".BranchConditionInjector").show();
      }
      else {
        this.$node.find(".BranchConditionInjector").hide();
      }
    },
    view: this
  });

  if(branch.$node.find(".BranchAnswer").length < 1) {
    branch.$node.find(".BranchConditionInjector").hide();
  }
  this._branchCount++;
  return branch;
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
    var url = utilities.stringInject(this.view.api.new_conditional, {
      conditional_index: String(this.view._branchCount - 1) // Because BE adds +1
    });

    utilities.updateDomByApiRequest(url, {
      target: $(BRANCH_SELECTOR).not(BRANCH_OTHERWISE_SELECTOR).last(),
      type: "after",
      done: function ($node) {
        BranchesController.createBranch.call(view, $node);
      }
    });
  }
}


/* Creates a menu to control options for branches in the view
 **/

/* We are creating new BranchCondition instances based on the original
 * HTML found. So that we can make each inserted component unique, we
 * need to alter the values that refer to the name attributes, etc.
 * This function takes the initial found jQuery node of original
 * Conditional component, served by the page, and copies the HTML.
 * It also alters the HTML by swapping in target points for adding
 * the required information in the right places.
 *
 * @$node (jQuery Node) HTML that will form the Branch
 **/
function createBranchConditionTemplate($node) {
  var html = $node.find(".condition").get(0).outerHTML;
  html = html.replace(
          /branch_conditionals_attributes_0_expressions_attributes_0_component/mig,
          "branch_conditionals_attributes_#{branch_index}_expressions_attributes_#{condition_index}_component");
  html = html.replace(
          /branch\[conditionals_attributes\]\[0\]\[expressions_attributes\]\[0\]\[component\]/mig,
          "branch[conditionals_attributes][#{branch_index}][expressions_attributes][#{condition_index}][component]");
  return html;
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
