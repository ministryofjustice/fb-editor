/**
 * BranchDestination Component
 * ----------------------------------------------------
 *
 * Description:
 * Creates a BranchDestination object from HTML in source.
 * A BranchDestination object can be used within (as part of) a Branch
 * component or as an independent object.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 **/


const utilities = require('./utilities');


/* BranchDestination
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class BranchDestination {
  constructor($node, config) {
    var conf = utilities.mergeObjects({
      css_classes_error: ""
    }, config);

    $node.addClass("BranchDestination");
    $node.data("instance", this);

    $node.on("change", () => {
      this.clearErrorState();
    });

    this._config = conf;
    this.$node = $node;
  }

  clearErrorState() {
    var classes = this._config.css_classes_error.split(" ");

    // First remove any injected error messages.
    this.$node.find(this._config.selector_error_messsage).remove();

    // Next clear any added error classes designed to pick up error css.
    this.$node.removeClass(classes);
    for(var i=0; i < classes.length; ++i) {
      this.$node.find("." + classes[i]).removeClass(classes[i]);
    }
  }
}


// Make available for importing.
module.exports = BranchDestination;

