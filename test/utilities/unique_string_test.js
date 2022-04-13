require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('uniqueString', function() {
  it('should return a string without passed arguments', function() {
    expect(utilities.uniqueString().constructor).to.equal(String().constructor);
    expect(typeof utilities.uniqueString()).to.equal("string");
  });

  it('should return a string that include the passed string value', function() {
    var str = 'mystringvalue';
    expect(utilities.uniqueString(str).constructor).to.equal(String().constructor);
    expect(typeof utilities.uniqueString(str)).to.equal("string");
  });

  it('should not return the same string value', function() {
    var str = 'mystringvalue';
    var str1 = utilities.uniqueString(str);
    var str2 = utilities.uniqueString(str);
    expect(str1).to.not.equal(str2);
  });
});
