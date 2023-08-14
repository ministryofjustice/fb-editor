const utilities = require('./utilities');

class ContentVisibilityInjector {
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
    $(document.body).trigger("ContentVisibilityInjector_Add");
  }
}



// Make available for importing.
module.exports = ContentVisibilityInjector;

