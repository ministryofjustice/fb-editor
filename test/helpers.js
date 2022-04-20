/* Helpers for use across all test scripts can go here.
 * To use them, require this file in your local test
 * helpers.js file and add to the module.exports. When
 * requiring local helpers.js file in your actual tests,
 * these helpers should be made available as helpers.blah
 *
 **/


// Hijack $.get to fake a server response
class jQueryGetOverride {
  #original;
  #done;

  constructor() {
    this.#original = $.get;
  }

  html(response, ready) {
    var self = this;
    $.get = function(urlNotNeeded, callback) {
      setTimeout(function() {
        callback(response);
        if(self.#done && typeof self.#done == "function") {
          self.#done();
          ready();
        }
      }, 100);
      return self;
    }
  }

  // Mimic (basic) done functionality.
  done(func) {
    this.#done = func || function() {};
  }

  restore() {
    $.get = this.#original;
  }
}



module.exports = {
  jQueryGetOverride: jQueryGetOverride
}
