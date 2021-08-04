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
    var conf = utilities.mergeObjects({}, config);
    $node.addClass("Branch");

    this._config = conf;
    this.view = conf.view;
    this.$node = $node;
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
    var conf = utilities.mergeObjects({}, config);

    $node.addClass("BranchCondition");
    this._config = conf;
    this.$node = $node;
  }
}


// Make available for importing.
module.exports = Branch;

