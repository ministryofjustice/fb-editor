require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.sortNumberArrayValues', function() {
  it('should return number array sorted low to high', function() {
    var arr = [10,2,34,12,5,28];
    var result = result = utilities.sortNumberArrayValues(arr);

    expect(result.constructor).to.equal(arr.constructor);
    expect(result).to.not.equal(arr);
    expect(result[2]).to.not.equal(arr[2]);
    expect(result[1]).to.equal(5);
    expect(result[2]).to.equal(10);
    expect(result[3]).to.equal(12);
  });

  it('should return a copy array not the original', function() {
    var arr = [10,2,34,12,5,28];
    var result = arr;
    expect(result).to.equal(arr);

    result = utilities.sortNumberArrayValues(arr);
    expect(result.length).to.equal(arr.length);
    expect(result).to.not.equal(arr);
  });

  it('should return empty array when given incorrect input', function() {
    var result = utilities.sortNumberArrayValues("This is not an array");
    expect(result.constructor).to.equal([].constructor);
    expect(result.length).to.equal(0);
  });
});
