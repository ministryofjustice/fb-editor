/**
 * Branch Injector Component
 * ----------------------------------------------------
 *
 * Description:
 * Creates a branch injector object from HTML in source
 *
 * Documentation:
 *
 *     - TODO:
 *       /documentation/services/editor/javascript/component-branch-injector.html
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');


/* Creates a BranchInjector object from passed $node.
 * BranchInjectors fetch new HTML for a branch that will
 * be added to the DOM and turned into a Branch object.
 **/
class BranchInjector {
  #config;

  constructor($node, config) {
    var injector = this;
    var conf = utilities.mergeObjects({}, config);

    this.#config = conf;
    $node.on("click", function(e) {
      e.preventDefault();
      injector.add();
    });
  }

  add() {
    // This should really be something like `new Branch(); and stuff` here
    // but, because much of it is haneled by the view and design requirements,
    // we're just triggering an event to allow the document to know it is
    // required. The view controller can pick up on this request for action
    // and make DOM adjustments based on what it needs to happen, passing
    // appropriate params to the available `new Branch()` fucntionality.
    $(document.body).trigger("BranchInjector_Add");
  }
}



// Make available for importing.
module.exports = BranchInjector;

