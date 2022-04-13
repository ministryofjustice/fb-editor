require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.property', function() {
  it('should return the specified top level property value', function() {
    var obj1 = {
      something: {
        goes: 'here'
      }
    }

    expect(utilities.property(obj1, 'something')).to.deep.equal({ goes: 'here' });
  });

  it('should return the specified inner level property value', function() {
    var obj2 = {
      something: {
        goes: 'here'
      }
    }

    expect(utilities.property(obj2, 'something.goes')).to.equal('here');
  });

  it('should return the specified deep inner level property value', function() {
    var obj3 = {
      something: {
        goes: {
          here: 'inside'
        }
      }
    }
    expect(utilities.property(obj3, 'something.goes.here')).to.equal('inside');
  });
});
