/**
 * Branch Component
 * ----------------------------------------------------
 *
 * Description:
 * Creates a branch object from HTML in source
 *
 * Documentation:
 *   [SOURCE] https://github.com/ministryofjustice/moj-forms-tech-docs/ ...
 *   [VIEW  ] https://ministryofjustice.github.io/moj-forms-tech-docs/ ...
 *
 *        ... documentation/services/editor/javascript/component-branch.html
 *
 **/


const utilities = require('./utilities');
const BranchDestination = require('./component_branch_destination');
const EVENT_QUESTION_CHANGE = "BranchQuestion_Change";


/* Branch component
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 *                  {
 *                    css_classes_error: <Removes error classes on component and removes injected error elements by class match>
 *                  }
 **/
class Branch {
  #config;
  #conditions; // Stores created BranchConditions
  #conditionCount; // TODO: Maybe remove if we can find way to use the #conditions.length
  #index; // Index number of the Branch

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
      branch.#conditionCount = index;
      branch.#createCondition($node);
    });

    $(document).trigger('BranchCreate', this);
  }

  get index() {
    return this.#index;
  }

  get conditions() {
    return this.#conditions;
  }

  addCondition() {
    var index = this.#conditionCount + 1;
    var $node = $(utilities.stringInject(this.#config.template_condition, {
      branch_index: this.#index,
      condition_index: index // Need unique value only but would be nice to use BranchCondition.index instead.
    }));

    this.#conditionCount = index;
    this.#createCondition($node);
    this.conditionInjector.$node.before($node);
  }

  removeCondition(condition) {
    // Find and remove from conditions array
    for(var i=0; i<this.#conditions.length; ++i) {
      if(this.#conditions[i] == condition) {
        this.#conditions.splice(i, 1);
      }
    }

    this.#updateConditions();
  }

  destroy() {
    // 1. Anything specifig to this function here.
    this.$node.remove();

    // 2. Then trigger the related event for listeners.
    $(document).trigger('Branch_Destroy', this);
  }

  #createCondition($node) {
    var condition = new BranchCondition($node, utilities.mergeObjects(this.#config, {
      index: this.#conditionCount
    }));

    this.#conditions.push(condition);
    this.#updateConditions();
  }

  #updateConditions() {
    // Set whether it is the only one, or not.
    if(this.#conditions.length < 2) {
      this.$node.addClass("singleBranchCondition");
    }
    else {
      this.$node.removeClass("singleBranchCondition");
    }

    this.$node.trigger("Branch_UpdateConditions");
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
    this.#index = conf.index;
    this.$node = $node;
    this.branch = conf.branch;
    this.question = new BranchQuestion($node.find(conf.selector_question), conf);
    this.remover = new BranchConditionRemover($remover, conf);
    this.answer = new BranchAnswer($node.find(conf.selector_answer), conf);
  }

  update(component, callback) {
    var url;
    if(component) {
      url = utilities.stringInject(this.#config.answer_url, {
        component_id: component,
        branch_index: this.branch.index,
        condition_index: this.#index
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

  destroy() {
    this.branch.removeCondition(this);
    this.$node.remove();
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
    this.condition.destroy();
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

    this.#config = conf;
    this.condition = conf.condition;
    this.$node = $node;
  }

  set label(label) {
    this.$node.find("label").text(label);
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
           // Just trigger an event
           $(document).trigger(EVENT_QUESTION_CHANGE, branch);
           this.enable();
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

    // Lastly remove any template injected error message classes identified by config.
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
      remover.activate();
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

  #action() {
    // 1. Trigger the related event for listeners.
    $(document).trigger("BranchRemover_Action", this);

    // 2. Finally pass off to the branch.
    this.branch.destroy();
  }

  // If a dialog confirmation action is required then we then trigger an event
  // to be picked up by the view. We pass the BranchRemover instance and the
  // required remover action to be handled by the view controller code.
  #confirm() {
    var remover = this;
    $(document).trigger("BranchRemover_Confirm", {
      instance: remover,
      action: remover.#action.bind(remover)
    });
  }

  // Check if confirmation is required or just run the action
  activate() {
    if(this.#config.confirmation_remove) {
      this.#confirm();
    }
    else {
      this.#action();
    }
  }
}


// Make available for importing.
module.exports = Branch;

