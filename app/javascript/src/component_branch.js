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

/* Branch component
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class Branch {
  constructor($node, config) {
    var conf = utilities.mergeObjects({ branch: this }, config);
    var $injector = $("<button></button>");
    $injector.text(conf.view.text.add_branch_condition);

    $node.addClass("Branch");
    $node.data("instance", this);
    $node.append($injector);

    this._config = conf;
    this.view = conf.view;
    this.$node = $node;
    this.index = $node.data(conf.attribute_branch_index);
    this.destination = new BranchDestination($node.find(config.destination_selector), conf);
    this.condition = new BranchCondition($node.find(config.condition_selector), conf);
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
    this.question = new BranchQuestion($node.find(conf.question_selector), conf);
    this.index = $node.data(conf.attribute_condition_index);
    this.$node = $node;
  }

  update(component) {
    var url;
    if(component) {
      url = utilities.stringInject(this._config.expression_url, {
        component_id: component,
        conditionals_index: this._config.branch.index,
        expressions_index: this.index
      });

      utilities.updateDomByApiRequest(url, {
        target: this.$node,
        done: ($node) => {
          this.answer = new BranchAnswer($node, this._config);
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
      this.change(e.currentTarget);
    });

    this._config = conf;
    this.condition = conf.condition;
    this.$node = $node;
  }

  change(select) {
    var supported = $(select.selectedOptions).data("supports-branching");
    this.clear();
    this.condition.clear();
    switch(supported) {
      case true: this.condition.update(select.value);
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

