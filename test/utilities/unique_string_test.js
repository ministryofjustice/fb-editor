require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.uniqueString', function() {
  it('should return a string without passed arguments', function() {
    expect(utilities.uniqueString().constructor).to.equal(String().constructor);
    expect(typeof utilities.uniqueString()).to.equal("string");
  });

  it('should return a string that include the passed string value', function() {
    var value = 'mystringvalue';
    var str = utilities.uniqueString(value);
    expect(str.constructor).to.equal(String().constructor);
    expect(typeof str).to.equal("string");
    expect(str).to.include(value);
  });

  it('should not return the same string value', function() {
    var str = 'mystringvalue';
    var str1 = utilities.uniqueString(str);
    var str2 = utilities.uniqueString(str);
    expect(str1).to.not.equal(str2);
  });
});
