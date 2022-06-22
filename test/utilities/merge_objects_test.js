require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');

describe('utilities.mergeObjects', function () {

  it('should merge object a into object b', function() {
    var a = {
      something: 'here'
    }

    var b = {
      another: 'thing'
    }

    expect(utilities.mergeObjects(a, b)).to.deep.equal({
      something: 'here',
      another: 'thing'
    });
  });

});
