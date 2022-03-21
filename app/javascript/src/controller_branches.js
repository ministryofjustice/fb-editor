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
 *       /documentation/services/editor/javascript/controller-branches.html
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');
const DefaultController = require('./controller_default');
const ActivatedMenu = require('./component_activated_menu');
const Branch = require('./component_branch');
const BranchInjector = require('./component_branch_injector');
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
  #branchIndex = 0;

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

  get branchIndex() {
    return this.#branchIndex;
  }

  set branchIndex(index) {
    this.#branchIndex = index;
  }

  /* ACTION SETUP:
   * Setup view for the create (new) action
   **/
  create() {
    var $branches = $(BRANCH_SELECTOR).not(BRANCH_OTHERWISE_SELECTOR);
    var $injectors = $(BRANCH_INJECTOR_SELECTOR);
    var $otherwise = $(BRANCH_OTHERWISE_SELECTOR + " " + BRANCH_DESTINATION_SELECTOR);

    this._branchConditionTemplate = createBranchConditionTemplate($branches.eq(0));

    BranchesController.addBranchEventListeners(this)
    BranchesController.enhanceCurrentBranches.call(this, $branches);
    BranchesController.enhanceBranchInjectors.call(this, $injectors);
    BranchesController.enhanceBranchOtherwise.call(this, $otherwise);
  }
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Find and enhance all current branches.
 **/
BranchesController.enhanceCurrentBranches = function($branches) {
  var view = this;
  $branches.each(function(index) {
    BranchesController.createBranch.call(view, $(this));
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Find and enhance all elements that can add a new branch.
 **/
BranchesController.enhanceBranchInjectors = function($injectors) {
  var view = this;
  $injectors.each(function() {
    new BranchInjector($(this));
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Find and enhance 'otherwise' destination with same/similar functionality
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
BranchesController.addBranchMenu = function(branch) {
  var $form = branch.$node.parent("form");
  var $ul = branch.$node.find(".component-activated-menu");
  var first = $(".Branch", $form).get(0) == branch.$node.get(0);
  new ActivatedMenu($ul, {
    activator_text: app.text.branches.branch_edit,
    container_classname: "SomeClassName",
    container_id: utilities.uniqueString("activated-menu-"),
    menu: {
      position: { my: "left top", at: "right-15 bottom-15" } // Position second-level menu in relation to first.
    }
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Creates a new branch from a passed element and keeps
 * track of number of branches
 **/
BranchesController.createBranch = function($node) {
  var view = this;
  var index = ++view.branchIndex;
  var branch = new Branch($node, {
    index: index,
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
    dialog_delete: view.dialogConfirmationDelete,
    view: view
  });

  branch.$node.on("UpdateConditions", function() {
    // Since the first Question label should be IF with the 
    // following ones AND, we have a visual update issue when
    // we delete the first one. This leaves us with AND, AND...
    // instead of IF, AND. This listener will correct found
    // incorrect labelling situations.
    branch.$node.find(BRANCH_QUESTION_SELECTOR + " label").eq(0).text(view.text.branches.label_question_if);
  });

  if(branch.$node.find(".BranchAnswer").length < 1) {
    branch.$node.find(".BranchConditionInjector").hide();
  }

  // Register/update the index tracker.
  view.branchIndex = index;

  return branch;
}

BranchesController.addBranchCombinator = function(branch) {
  if( branch.index != 0 ) {
    branch.$node.before("<p class=\"branch-or\">or</p>");
  }
}

BranchesController.removeBranchCombinator = function(node) {
    $(node).prev('.branch-or').first().remove();
}


/* Add document level listeners for adjusting the view based on Branch events.
 **/
BranchesController.addBranchEventListeners = function(view) {
  view.$document.on('BranchRemove', function(event, node){
    BranchesController.removeBranchCombinator.call(view, node);
  });

  view.$document.on("BranchInjector_Add", function() {
    var url = utilities.stringInject(view.api.new_conditional, {
      conditional_index: String(view.branchIndex - 1) // Because BE adds +1 (also BE calls Branches Conditionals - yes, confusing!)
    });

    utilities.updateDomByApiRequest(url, {
      target: $(BRANCH_SELECTOR).not(BRANCH_OTHERWISE_SELECTOR).last(),
      type: "after",
      done: function ($node) {
        BranchesController.createBranch.call(view, $node);
      }
    });
  });

  view.$document.on('BranchCreate', function(event, branch) {
    BranchesController.addBranchMenu(branch);
    BranchesController.addBranchCombinator(branch);
  });

  view.$document.on('BranchQuestionChange', function(event, branch) {
    if(branch.$node.find(".BranchAnswer").length > 0) {
      branch.$node.find(".BranchConditionInjector").show();
    }
    else {
      branch.$node.find(".BranchConditionInjector").hide();
    }
  });
}


/* We are creating new BranchCondition instances based on the original
 * HTML found. So that we can make each inserted component unique, we
 * need to alter the values that refer to the name attributes, etc.
 * This function takes the initial found jQuery node of original
 * Conditional component, served by the page, and copies the HTML.
 * It also alters the HTML by swapping in target points for adding
 * the required information in the right places.
 *
 * IMPORTANT: There should always be at least one .condition element in
 * the page content. This code fell over when, possibly due to an unfixed
 * bug, the html variable couldn't get some code, due to the target node
 * not having a .condition to find. To compensate (without fixing any
 * underlying issue that is in a separate ticket) the code has been
 * updated to try and find any .condition element if the preferred item
 * cannot be found. This is purely a second-chance addition and will
 * likely not fix the page should an incorrect scenario occur. It will,
 * however, have a chance to make it look better (less broken).
 *
 * @$node (jQuery Node) HTML that will form the Branch
 **/
function createBranchConditionTemplate($node) {
  var $condition = $node.find(".condition").clone();
  var html = "";

  // See IMPORTANT, above.
  if($condition.length == 0) {
    $condition = $(".condition").clone();
  }

  // We hope to have something but wrapping in test just in case we do not.
  if($condition.length) {

    // First clean up some stuff.
    $condition.find(".govuk-error-message").remove();
    $condition.removeClass("govuk-form-group--error");

    // Now take a copy of the HTML.
    html = $condition.get(0).outerHTML;
  }
  // html is a string, either empty or populated, so we should be safe from here.
  html = html.replace(
          /branch_conditionals_attributes_0_expressions_attributes_0_(component|operator|field)/mig,
          "branch_conditionals_attributes_#{branch_index}_expressions_attributes_#{condition_index}_$1");
  html = html.replace(
          /branch\[conditionals_attributes\]\[0\]\[expressions_attributes\]\[0\]\[(component|operator|field)\]/mig,
          "branch[conditionals_attributes][#{branch_index}][expressions_attributes][#{condition_index}][$1]");
  return html;
}


module.exports = BranchesController;
