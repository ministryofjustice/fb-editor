require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.lowestNumber', function() {
  it("should return the lowest number from those passed in", function() {
    expect(utilities.lowestNumber([12,41,6,18,100])).to.equal(6);
  })
;
  it("should return undefined when given bad data", function() {
    expect(utilities.lowestNumber("this is not an array")).to.equal(undefined);
  });
});
