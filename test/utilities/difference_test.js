require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.difference', function() {
  it("should return a - b when a is greater", function() {
    expect(utilities.difference(6, 2)).to.equal(4);
  });

  it("should return b - a when b is greater", function() {
    expect(utilities.difference(7, 12)).to.equal(5);
  });

  it("should return negative number when abs is false", function() {
    expect(utilities.difference(7,12, false)).to.equal(-5);
  })
});
