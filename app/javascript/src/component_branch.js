/**
 * Branch Component
 * ----------------------------------------------------
 *
 * Description:
 * Creates a branch object from HTML in source
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

const utilities = require('./utilities');
const BranchDestination = require('./component_branch_destination');
const EVENT_QUESTION_CHANGE = "branchquestionchange";


/* Branch component
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class Branch {
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
    $node.on(EVENT_QUESTION_CHANGE, () => {
      utilities.safelyActivateFunction.call(this, conf.event_question_change);
    });

    this._config = conf;
    this._index = Number(conf.branch_index);
    this._conditionCount = 0;
    this._conditions = {}; // Add only conditions that you want deletable to this.
    this.$node = $node;
    this.view = conf.view;
    this.destination = new BranchDestination($node.find(config.selector_destination), conf);
    this.conditionInjector = new BranchConditionInjector($injector, conf);
    this.remover = new BranchRemover($remover, conf);

    // Create BranchCondition instance found in Branch.
    this.$node.find(this._config.selector_condition).each(function(index) {
      var condition = new BranchCondition($(this), conf);
      if(index == 0) {
        condition.$node.find(".BranchConditionRemover").hide(); // So we always have one condition.
      }
      branch._conditions[condition.$node.attr("id")] = condition; // Might only have id AFTER creation of BranchCondition.
      branch._conditionCount++;
    });

    utilities.safelyActivateFunction(this._config.event_on_create, [this]);
  }

  addCondition() {
    var template = utilities.stringInject(this._config.template_condition, {
      branch_index: this._index,
      condition_index: ++this._conditionCount
    });

    var $condition = $(template);
    var condition = new BranchCondition($condition, this._config);
    this._conditions[$condition.attr("id")] = condition;
    this.conditionInjector.$node.before($condition);
  }

  removeCondition(id) {
    var $condition = this.$node.find("#" + id);
    delete this._conditions[id];
    $condition.remove();
  }

  destroy() {
    this.$node.remove();
  }
}


/* BranchCondition
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchCondition {
  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);
    var $remover = $(conf.selector_condition_remove, $node);

    if($node.attr("id") == "" || $node.attr("id") == undefined) {
      $node.attr("id", utilities.uniqueString("branch-condition_"));
    }

    $node.addClass("BranchCondition");
    $node.data("instance", this);
    $node.append($remover);

    this._config = conf;
    this._index = conf.branch._conditionCount;
    this.$node = $node;
    this.branch = conf.branch;
    this.question = new BranchQuestion($node.find(conf.selector_question), conf);
    this.remover = new BranchConditionRemover($remover, conf);
    this.answer = new BranchAnswer($node.find(conf.selector_answer), conf);
  }

  update(component, callback) {
    var url;
    if(component) {
      url = utilities.stringInject(this._config.expression_url, {
        component_id: component,
        conditionals_index: this._config.branch._index,
        expressions_index: this._index
      });

      utilities.updateDomByApiRequest(url, {
        target: this.$node,
        done: ($node) => {
          this.answer = new BranchAnswer($node, this._config);
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
  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);

    $node.addClass("BranchConditionInjector");
    $node.data("instance", this);
    $node.on("click", (e) => {
      e.preventDefault();
      conf.branch.addCondition();
    });

    this._config = conf;
    this.branch = conf.branch;
    this.$node = $node;
  }
}


/* BranchConditionRemover
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchConditionRemover {
  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);

    $node.addClass("BranchConditionRemover");
    $node.data("instance", this);
    $node.attr("aria-controls", conf.condition.$node.attr("id"));
    $node.on("click", (e) => {
      e.preventDefault();
      conf.branch.removeCondition(this.$node.attr("aria-controls"));
    });

    this._config = conf;
    this.condition = conf.condition;
    this.$node = $node;
  }
}


/* BranchQuestion
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchQuestion {
  constructor($node, config) {
    var conf = utilities.mergeObjects({}, config);

    $node.addClass("BranchQuestion");
    $node.data("instance", this);
    $node.find("select").on("change.branchquestion", (e) => {
      var select = e.currentTarget;
      var supported = $(select.selectedOptions).data("supports-branching");
      this.change(supported, select.value);
    });

    if(conf.condition._index > 0) {
      $node.find("label").text(config.question_label);
    }

    this._config = conf;
    this.condition = conf.condition;
    this.$node = $node;
  }

  change(supported, value) {
    var branch = this.condition.branch;
    this.clear();
    this.condition.clear();
    switch(supported) {
      case true:
           this.condition.update(value, function() {
             branch.$node.trigger(EVENT_QUESTION_CHANGE);
           });
           break;
      case false:
           this.error("unsupported");
           break;
      default:
           // Just trigger an event
           this.condition.branch.$node.trigger(EVENT_QUESTION_CHANGE);
    }
  }

  clear() {
    if(this._$error && this._$error.length > 0) {
      this._$error.remove();
      this._$error = null;
      this.condition.$node.removeClass("error");
    }
  }

  error(type) {
    var $error = $("<p class=\"error-message\"></p>");
    var errors = this._config.view.text.errors.branches;
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
  constructor($node, config) {
    var conf = utilities.mergeObjects({}, config);

    $node.addClass("BranchAnswer");
    $node.data("instance", this);
    this._config = conf;
    this.$node = $node;
  }
}


/* Create a BranchRemover object from pass $node.
 * BranchRemover will adjust the view by removing
 * a specified branch node from the DOM.
 **/
class BranchRemover {
  constructor($node, config) {
    var conf = utilities.mergeObjects({}, config);
    var branch = conf.branch;

    $node.addClass("BranchRemover");;
    $node.data("instance", this);
    $node.attr("aria-controls", conf.branch.$node.attr("id"));
    $node.on("click", (e) => {
      e.preventDefault();
      branch.destroy();
    });

    this._config = conf;
    this.branch = branch;
    this.$node = $node;
  }
}

// Make available for importing.
module.exports = Branch;

