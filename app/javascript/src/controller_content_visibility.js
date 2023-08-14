
const utilities = require('./utilities');
const DefaultController = require('./controller_default');
const ActivatedMenu = require('./components/menus/activated_menu');
const ContentVisibility = require('./component_content_visibility');
const ContentVisibilityInjector = require('./component_content_visibility_injector');
const CONTENT_VISIBILITY_SELECTOR = ".content-visibility";
const CONTENT_VISIBILITY_ANSWER_SELECTOR = ".answer";
const CONTENT_VISIBILITY_CONDITION_SELECTOR = ".condition";
const CONTENT_VISIBILITY_CONDITION_ADD_SELECTOR = ".condition-injector";
const CONTENT_VISIBILITY_QUESTION_SELECTOR = ".question";
const CONTENT_VISIBILITY_INJECTOR_SELECTOR = "#add-another-content-visibility";
const EVENT_CONTENT_VISIBILITY_UPDATE_CONDITIONS = "ContentVisibility_UpdateConditions";
const EVENT_QUESTION_CHANGE = "ContentVisibilityQuestion_Change";

class ContentVisibilityController extends DefaultController {
  #contentVisibilityIndex = 0;

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

  get contentVisibilityIndex() {
    return this.#contentVisibilityIndex;
  }

  set contentVisibilityIndex(index) {
    this.#contentVisibilityIndex = index;
  }

  get contentVisibilityNodes() {
    return $(CONTENT_VISIBILITY_SELECTOR);
  }

  create() {
    var $content = this.contentVisibilityNodes;
    var $injectors = $(CONTENT_VISIBILITY_INJECTOR_SELECTOR);

    this.contentVisibilityConditionTemplate = createContentVisibilityConditionTemplate($content.eq(0));

    ContentVisibilityController.addContentVisibilityEventListeners(this)
    ContentVisibilityController.enhanceCurrentContentVisibility.call(this, $content);
    ContentVisibilityController.enhanceContentVisibilityInjector.call(this, $injectors);
  }
}

ContentVisibilityController.enhanceCurrentContentVisibility = function($content) {
  var view = this;
  $content.each(function(index) {
    var content_visibility = createContentVisibility(view, $(this));
    content_visibility.$node.trigger(EVENT_CONTENT_VISIBILITY_UPDATE_CONDITIONS);
  });

  updateContentVisibility(view);
}

ContentVisibilityController.enhanceContentVisibilityInjectors = function($injectors) {
  $injectors.each(function() {
    new ContentVisibilityInjector($(this));
  });
}

function createContentVisibility(view, $node) {
  var content_visibility = new ContentVisibility($node, {
    index: view.contentVisibilityIndex,
    // css_classes_error: CSS_CLASS_ERRORS,
    selector_answer: CONTENT_VISIBILITY_ANSWER_SELECTOR,
    // selector_branch_remove: CONTENT_VISIBILITY_REMOVE_SELECTOR,
    selector_condition: CONTENT_VISIBILITY_CONDITION_SELECTOR,
    selector_condition_add: CONTENT_VISIBILITY_CONDITION_ADD_SELECTOR,
    // selector_condition_remove: CONTENT_VISIBILITY_CONDITION_REMOVE_SELECTOR,
    // selector_error_messsage: CONTENT_VISIBILITY_ERROR_MESSAGE_SELECTOR,
    selector_question: CONTENT_VISIBILITY_QUESTION_SELECTOR,
    answer_url: view.api.get_expression,
    // dialog_delete: view.dialogConfirmationDelete,
    template_condition: view.contentVisibilityConditionTemplate,
    confirmation_remove: true,
    view: view,
  });

  // Add new branch view changes.
  // addBranchMenu(branch);
  // addBranchCombinator(branch)
  $(document).trigger(EVENT_QUESTION_CHANGE, content_visibility);

  view.contentVisibilityIndex = view.contentVisibilityIndex + 1;

  // Since the first Question label should be IF with the
  // following ones AND, we have a visual update issue when
  // we delete the first one. This leaves us with AND, AND...
  // instead of IF, AND. This listener will correct found
  // incorrect labelling situations.
  content_visibility.$node.on(EVENT_CONTENT_VISIBILITY_UPDATE_CONDITIONS, function() {
    for(var i=0; i<content_visibility.conditions.length; ++i) {
      if(i == 0) {
        content_visibility.conditions[i].question.label = view.text.content_visibility.label_question_if;
      }
      else {
        content_visibility.conditions[i].question.label = view.text.content_visibility.label_question_and;
      }
    }
  });

  return content_visibility;
}

function updateContentVisibility(view) {
  var $first = view.contentVisibilityNodes.eq(0);

  if(view.contentVisibilityNodes.length > 1) {
    $first.find(".ActivatedMenuActivator").show();
    $first.data("instance").remover.enable();
  }
  else {
    $first.find(".ActivatedMenuActivator").hide();
    $first.data("instance").remover.disable();
  }

  // 2. Remove first 'or'.
  // removeBranchCombinator(view.contentVisibilityNodes.eq(0));
}

ContentVisibilityController.addContentVisibilityEventListeners = function(view) {
  // view.$document.on("Branch_Destroy", function(event, branch){
  //   updateBranches(view);
  // });

  // view.$document.on(EVENT_BRANCH_REMOVER_ACTION, function(event, remover) {
  //   removeBranchCombinator(remover.branch.$node);
  // });

  view.$document.on("ContentVisibilityInjector_Add", function() {
    var url = utilities.stringInject(view.api.new_conditional, {
      content_visibility_index: String(view.contentVisibilityIndex - 1)
    });

    utilities.updateDomByApiRequest(url, {
      target: view.contentVisibilityNodes.last(),
      type: "after",
      done: function ($node) {
        createContentVisibility(view, $node);
        updateContentVisibility(view);
      }
    });
  });

  // view.$document.on(EVENT_BRANCH_REMOVER_CONFIRM, function(event, data) {
  //   view.dialogConfirmationDelete.onConfirm = data.action;
  //   view.dialogConfirmationDelete.open({
  //     heading: view.text.dialogs.heading_delete_branch,
  //     content: view.text.dialogs.message_delete_branch,
  //     confirm: view.text.dialogs.button_delete_branch
  //   });
  // });

  view.$document.on(EVENT_QUESTION_CHANGE, function(event, content_visibility) {
    if(content_visibility.$node.find(".ContentVisibilityAnswer").length > 0) {
      content_visibility.$node.find(".ContentVisibilityConditionInjector").show();
    }
    else {
      content_visibility.$node.find(".ContentVisibilityConditionInjector").hide();
    }
  });
}

function createContentVisibilityConditionTemplate($node) {
  var $condition = $node.find(".condition").eq(0).clone();
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

    // Should not have a question selected so also get rid of answers from cloning.
    $condition.find(".answer").remove();
    $condition.find("option").attr("selected", false).eq(0).attr("selected", true);

    // Now take a copy of the HTML.
    html = $condition.get(0).outerHTML;
  }

  html = html.replace(
          /conditional_content_conditionals_attributes_0_expressions_attributes_0_(component|operator|field)/mig,
          "conditional_content_conditionals_attributes_#{content_visibility_index}_expressions_attributes_#{condition_index}_$1");
  html = html.replace(
          /conditional_content\[conditionals_attributes\]\[0\]\[expressions_attributes\]\[0\]\[(component|operator|field)\]/mig,
          "conditional_content[conditionals_attributes][#{content_visibility_index}][expressions_attributes][#{condition_index}][$1]");
  return html;
}

module.exports = ContentVisibilityController;
