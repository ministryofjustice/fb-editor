require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.highestNumber', function() {
  it("should return the highest number from those passed in", function() {
    expect(utilities.highestNumber([41,6,18,100,12])).to.equal(100);
  })
;
  it("should return undefined when given bad data", function() {
    expect(utilities.highestNumber("this is not an array")).to.equal(undefined);
  });
});
