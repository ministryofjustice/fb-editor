/**
 * Branch Component
 * ----------------------------------------------------
 *
 * Description:
 * Creates a branch object from HTML in source
 *
 * Documentation:
 *
 *     - TODO:
 *       /documentation/services/editor/javascript/component-branch.html
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');
const BranchDestination = require('./component_branch_destination');
const EVENT_QUESTION_CHANGE = "BranchQuestionChange";


/* Branch component
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class Branch {
  #config;
  #conditions; // Stores created BranchConditions
  #conditionCount; // TODO: Maybe remove if we can find way to use the #conditions.length
  #index; // Index number of the Branch

  #conditionTemplate() {
    return utilities.stringInject(this.#config.template_condition, {
      branch_index: this.#index,
      condition_index: ++this.#conditionCount // Need unique value only but would be nice to use BranchCondition.index instead.
    });
  }

  #createCondition($node) {
    var condition = new BranchCondition($node, this.#config);
    this.#conditions.push(condition);
    this.#updateConditions();
  }

  #updateConditions() {
    // Reindex the conditions
    for(var i=0; i<this.#conditions.length; ++i) {
      this.#conditions[i].index = i;
    }

    // Set whether it is the only one, or not.
    if(this.#conditions.length < 2) {
      this.$node.addClass("singleBranchCondition");
    }
    else {
      this.$node.removeClass("singleBranchCondition");
    }

    this.$node.trigger("UpdateConditions");
  }

  constructor($node, config) {
    var branch = this;
    var conf = utilities.mergeObjects({ branch: this }, config);
    var $injector = $(conf.selector_condition_add, $node);
    var $remover = $(conf.selector_branch_remove, $node);

    if($node.attr("id") == "" || $node.attr("id") == undefined) {
      $node.attr("id", utilities.uniqueString("branch_"));
    }

    $node.addClass("Branch");
    $node.data("instance", this);

    this.#config = conf;
    this.#conditions = [];
    this.#conditionCount = 0;
    this.#index = Number(conf.index);
    this.$node = $node;
    this.view = conf.view;
    this.destination = new BranchDestination($node.find(config.selector_destination), conf);
    this.conditionInjector = new BranchConditionInjector($injector, conf);
    this.remover = new BranchRemover($remover, conf);

    // Create BranchCondition instance found in Branch.
    this.$node.find(this.#config.selector_condition).each(function(index) {
      var $node = $(this);
      branch.#createCondition($node);
    });

    $(document).trigger('BranchCreate', this);
  }

  get index() {
    return this.#index;
  }

  addCondition() {
    var $node = $(this.#conditionTemplate());
    this.#createCondition($node);
    this.conditionInjector.$node.before($node);
  }

  removeCondition(i) {
    this.#conditions[i].$node.remove(); // Remove from DOM
    this.#conditions.splice(i, 1); // Remove item at i
    this.#updateConditions();
  }

  destroy() {
    // 1. Anything specifig to this function here.
    this.$node.remove();

    // 2. Then trigger the related event for listeners.
    $(document).trigger('Branch_Destroy', this);
  }
  
}


/* BranchCondition
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchCondition {
  #config;
  #index;

  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);
    var $remover = $(conf.selector_condition_remove, $node);

    if($node.attr("id") == "" || $node.attr("id") == undefined) {
      $node.attr("id", utilities.uniqueString("branch-condition_"));
    }

    $node.addClass("BranchCondition");
    $node.data("instance", this);
    $node.append($remover);

    this.#config = conf;
    this.$node = $node;
    this.branch = conf.branch;
    this.question = new BranchQuestion($node.find(conf.selector_question), conf);
    this.remover = new BranchConditionRemover($remover, conf);
    this.answer = new BranchAnswer($node.find(conf.selector_answer), conf);
  }

  get index() {
    return this.#index;
  }

  set index(value) {
    this.#index = value;

    // Note: We should really have something here that also updates the
    // attributes used in form submission so they take into account any
    // changes to index values, but that's not currently how things are
    // handled in the frontend. Because we're giving control to the
    // server, so long as the required node attributes are different in
    // the HTML, the server will sort out a proper index order and that
    // will be seen after form submit and page is refreshed. If things
    // were to change and frontend had to control such matters, this
    // is the place where things should start. That is why this function
    // exists and/or only currently does the one-liner action above.
  }

  update(component, callback) {
    var url;
    if(component) {
      url = utilities.stringInject(this.#config.expression_url, {
        component_id: component,
        conditionals_index: this.#config.branch.index,
        expressions_index: this.#index
      });

      utilities.updateDomByApiRequest(url, {
        target: this.$node,
        done: ($node) => {
          this.answer = new BranchAnswer($node, this.#config);
          utilities.safelyActivateFunction(callback);
        }
      });
    }
  }

  clear() {
    // Clear any existing
    if(this.answer) {
      this.answer.$node.remove();
      this.answer = null;
    }
  }
}


/* BranchConditionInjector
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchConditionInjector {
  #config;

  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);

    $node.addClass("BranchConditionInjector");
    $node.data("instance", this);
    $node.on("click", (e) => {
      e.preventDefault();
      conf.branch.addCondition();
    });

    this.#config = conf;
    this.branch = conf.branch;
    this.$node = $node;
  }
}


/* BranchConditionRemover
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 *                  e.g. {
 *                         onConditionRemove: function() {} // Set an action to happen, if required.
 *                       }
 **/
class BranchConditionRemover {
  #config;

  constructor($node, config) {
    var remover = this;
    var conf = utilities.mergeObjects({ condition: this }, config);

    $node.addClass("BranchConditionRemover");
    $node.data("instance", this);
    $node.attr("aria-controls", conf.condition.$node.attr("id"));
    $node.on("click", (e) => {
      e.preventDefault();
      remover.confirm();
    });

    this.#config = conf;
    this.condition = conf.condition;
    this.$node = $node;
  }

  confirm() {
    var dialog = this.#config.dialog_delete;
    var text = this.#config.view.text;
    if(dialog) {
      // If we have set a confirmation dialog, use it...
      this.#config.dialog_delete.open({
        heading: text.dialogs.heading_delete_condition,
        content: text.dialogs.message_delete_condition,
        ok: text.dialogs.button_delete_condition
      }, this.activate.bind(this));
    }
    else {
      // ... otherwise just activate the functionality.
      this.activate();
    }
  }

  activate() {
    this.#config.branch.removeCondition(this.#config.condition.index);
  }
}


/* BranchQuestion
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchQuestion {
  #config;
  #index;

  constructor($node, config) {
    var conf = utilities.mergeObjects({
      css_classes_error: ""
    }, config);

    $node.addClass("BranchQuestion");
    $node.data("instance", this);
    $node.find("select").on("change.branchquestion", (e) => {
      var select = e.currentTarget;
      var supported = $(select.selectedOptions).data("supports-branching");
      this.disable();
      this.change(supported, select.value);
    });

    if(conf.condition.index > 0) {
      $node.find("label").text(config.question_label);
    }

    this.#config = conf;
    this.condition = conf.condition;
    this.$node = $node;
  }

  disable() {
    this.$node.find('select').prop('disabled', true);
  }

  enable() {
    this.$node.find('select').prop('disabled', false);
  }

  change(supported, value) {
    var branch = this.condition.branch;
    this.clearErrorState();
    this.condition.clear();
    switch(supported) {
      case true:
           this.condition.update(value, () =>  {
             $(document).trigger(EVENT_QUESTION_CHANGE, branch);
             this.enable();
           });
           break;
      case false:
           this.error("unsupported");
           this.enable();
           break;
      default:
           this.enable();
           // Just trigger an event
           $(document).trigger(EVENT_QUESTION_CHANGE, this.condition.branch);
    }
  }

  clearErrorState() {
    var classes = this.#config.css_classes_error.split(" ");

    // First clear anything added by error() method.
    this.condition.$node.removeClass("error");
    this.condition.$node.removeClass(this.#config.css_classes_error);

    if(this._$error && this._$error.length > 0) {
      this._$error.remove();
      this._$error = null;
    }

    // Second remove any template injected error messages identified by config.
    this.condition.$node.find(this.#config.selector_error_messsage).remove();

    // Lastley remove any template injected error message classes identified by config.
    for(var i=0; i < classes.length; ++i) {
      if(classes[i].length > 0) {
        this.$node.removeClass(classes[i]);
        this.$node.find("." + classes[i]).removeClass(classes[i]);
      }
    }
  }

  error(type) {
    var $error = $("<p class=\"error-message\"></p>");
    var errors = this.#config.view.text.errors.branches;
    switch(type) {
      case "unsupported": $error.text(errors.unsupported_question);
        break;
      default: $error.text("An error occured");
    }

    this._$error = $error;
    this.$node.append($error);
    this.condition.$node.addClass("error");
  }
}


/* BranchAnswer
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchAnswer {
  #config;

  constructor($node, config) {
    var conf = utilities.mergeObjects({}, config);

    $node.addClass("BranchAnswer");
    $node.data("instance", this);
    this.#config = conf;
    this.$node = $node;
    
    this.showHideAnswers();

    this.$node.find('[data-expression-operator]').on('change', (event) =>  {
      this.showHideAnswers();
    }); 
  }

  showHideAnswers() {
    var $condition = this.$node.find('[data-expression-operator]');
    var $answer = this.$node.find('[data-expression-answer]');
    var hideAnswers = $condition.find(':selected').data('hide-answers');

    if(hideAnswers) {
      $answer.hide();
      $answer.val([]);
    } else {
      $answer.show();
      if( !$answer.val() ) {
        $answer.val( $answer.find('option:first').val() );
      }
    }
  }
}


/* Create a BranchRemover object from pass $node.
 * BranchRemover will adjust the view by removing
 * a specified branch node from the DOM.
 **/
class BranchRemover {
  #config;
  #disabled = false;

  constructor($node, config) {
    var remover = this;
    var conf = utilities.mergeObjects({}, config);

    $node.addClass("BranchRemover");
    $node.data("instance", this);
    $node.attr("aria-controls", conf.branch.$node.attr("id"));
    $node.on("click", (e) => {
      e.preventDefault();
      remover.confirm();
    });

    this.#config = conf;
    this.branch = conf.branch;
    this.$node = $node;
  }

  disable() {
    this.$node.addClass("disabled");
    this.#disabled = true;
  }

  enable() {
    this.$node.removeClass("disabled");
    this.#disabled = false;
  }

  isDisabled() {
    return this.#disabled;
  }

  confirm() {
    var dialog = this.#config.dialog_delete;
    var text = this.#config.view.text;
    if(dialog) {
      // If we have set a confirmation dialog, use it...
      this.#config.dialog_delete.open({
        heading: text.dialogs.heading_delete_branch,
        content: text.dialogs.message_delete_branch,
        ok: text.dialogs.button_delete_branch
      }, this.activate.bind(this));
    }
    else {
      // ... otherwise just activate the functionality.
      this.activate();
    }
  }

  activate() {
    // 1. Anything specific to this function here.
    // ... nothing ...

    // 2. Then trigger the related event for listeners.
    $(document).trigger("BranchRemover_Activate", this);

    // 3. Finally pass off to the branch.
    this.branch.destroy();
  }
}


// Make available for importing.
module.exports = Branch;

