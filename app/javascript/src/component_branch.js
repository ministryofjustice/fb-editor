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
const EVENT_CONDITION_UPDATE = "branchconditionupdate";


/* Branch component
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class Branch {
  constructor($node, config) {
    var conf = utilities.mergeObjects({ branch: this }, config);
    var $injector = $("<button />");

    $node.addClass("Branch");
    $node.data("instance", this);
    $node.append($injector);
    $node.on(EVENT_CONDITION_UPDATE, () => {
      this.conditionInjector.$node.show();
    });

    this._config = conf;
    this._index = Number(conf.branch_index);
    this._conditionCount = 0;
    this.$node = $node;
    this.view = conf.view;
    this.destination = new BranchDestination($node.find(config.selector_destination), conf);
    this.conditionInjector = new BranchConditionInjector($injector, conf);
    this.conditionInjector.$node.hide();

    // Create BranchCondition instance found in Branch.
    this.$node.find(this._config.selector_condition).each(function() {
      new BranchCondition($(this), conf);
      this._conditionCount++;
    });
  }

  addCondition() {
    var template = utilities.stringInject(this._config.template_condition, {
      branch_index: this._index,
      condition_index: ++this._conditionCount
    });
    var $condition = $(template);
    new BranchCondition($condition, this._config);
    this.conditionInjector.$node.before($condition);
  }
}


/* BranchDestination
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchDestination {
  constructor($node, config) {
    var conf = utilities.mergeObjects({}, config);

    $node.addClass("BranchDestination");
    $node.data("instance", this);
    this._config = conf;
    this.$node = $node;
  }
}


/* BranchCondition
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchCondition {
  constructor($node, config) {
    var conf = utilities.mergeObjects({ condition: this }, config);

    $node.addClass("BranchCondition");
    $node.data("instance", this);

    this._config = conf;
    this._index = conf.branch._conditionCount;
    this.branch = conf.branch;
    this.question = new BranchQuestion($node.find(conf.selector_question), conf);
    this.$node = $node;
  }

  update(component) {
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
          this.branch.$node.trigger(EVENT_CONDITION_UPDATE);
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

    $node.text(conf.view.text.branches.add_condition);
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
    this.clear();
    this.condition.clear();
    switch(supported) {
      case true: this.condition.update(value);
           break;
      case false: this.error("unsupported");
           break;
      default: // Nothing to see here. Probably on the initial option without support attribute.
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


// Make available for importing.
module.exports = Branch;

