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
    $node.addClass("Branch");
    $node.data("instance", this);

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
    var condition = this;
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
    else {
      // Clear any existing
      if(this.answer) {
        this.answer.$node.remove();
        this.answer = null;
      }
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
      this.condition.update(e.currentTarget.value);
    });

    this._config = conf;
    this.condition = conf.condition;
    this.$node = $node;
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

