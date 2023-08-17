
const utilities = require('./utilities');
const DefaultController = require('./controller_default');
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
    ContentVisibilityController.enhanceContentVisibilityInjectors.call(this, $injectors);
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
    selector_answer: CONTENT_VISIBILITY_ANSWER_SELECTOR,
    selector_condition: CONTENT_VISIBILITY_CONDITION_SELECTOR,
    selector_condition_add: CONTENT_VISIBILITY_CONDITION_ADD_SELECTOR,
    selector_question: CONTENT_VISIBILITY_QUESTION_SELECTOR,
    answer_url: view.api.get_expression,
    template_condition: view.contentVisibilityConditionTemplate,
    confirmation_remove: true,
    view: view,
  });


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
}

ContentVisibilityController.addContentVisibilityEventListeners = function(view) {
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
