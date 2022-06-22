require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');

describe('utilities.safelyActivateFunction', function() {
  it('should fail silently when not a function', function() {
    try {
      utilities.safelyActivateFunction('I am a string');
      expect('Safely Executed').is.ok;
    } catch(e) {
      if(e instanceof TypeError) {
        expect.toThrow('TypeError created by non-function');
      }
    }
  });

  it('should run the function passed to it without arguments', function() {
    var a = 1;
    utilities.safelyActivateFunction(function(){ a++; });
    expect(a).to.not.equal(1);
    expect(a).to.equal(2);
  });

  it('should run the function passed to it including arguments', function() {
    var a = 1;
    var func = function(b) {
      a = b;
    }

    utilities.safelyActivateFunction(func(3));
    expect(a).to.not.equal(1);
    expect(a).to.equal(3);
  });
});
