require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.isBoolean', function() {
  it('should return false if a String is checked', function() {
    expect(utilities.isBoolean("a string")).to.be.false;
  });

  it('should return true if a Boolean is checked', function() {
    expect(utilities.isBoolean(true)).to.be.true;
  });
});
