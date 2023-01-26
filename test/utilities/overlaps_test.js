require('../setup');

const utilities = require('../../app/javascript/src/utilities');

describe('utilties.overlaps', function() {

  it('should return true if ranges overlap', function() {
    let a = { start: 10, end: 100 };
    let b = { start: 50, end: 150};

    expect(utilities.overlaps(a,b)).to.be.true;
  });

  it('should return true if ranges overlap more than minimum', function() {
    let a = { start: 10, end: 100};
    let b = { start: 50, end: 150};

    expect(utilities.overlaps(a,b, 10)).to.be.true;
  });

  it('should return false if ranges overlap but less than minimum', function() {
    let a = { start: 10, end: 100};
    let b = { start: 50, end: 150};

    expect(utilities.overlaps(a,b, 100)).to.be.false;
  });

  it('should return false if there is no overlap', function() {
    let a = { start: 10, end: 100};
    let b = { start: 120, end: 200};

    expect(utilities.overlaps(a,b, 100)).to.be.false;
  })
});
