require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.isFunction', function() {
  it('should return true if type is a function', function() {
    var thisIsAFunction = function() {};
    expect(utilities.isFunction(thisIsAFunction)).to.be.true;
  });

  it('should return false if type is not a function', function() {
    var thisIsNotAFunction = 'I am a string';
    expect(utilities.isFunction(thisIsNotAFunction)).to.be.false;;
  });
});
