require("../setup");
const utilities = require('../../app/javascript/src/utilities');

describe('utilities.intersects', function() {

  it('should return true if bounds intersect', function() {
    let a = { x1: 100, y1: 100, x2: 600, y2: 200 };
    let b = { x1: 200, y1: 150, x2: 600, y2: 200 };

    expect(utilities.intersects(a,b)).to.be.true;
  })

  it('should return false if vertical bounds do not intersect', function() {
    let a = { x1: 100, y1: 100, x2: 600, y2: 200 };
    let b = { x1: 300, y1: 300, x2: 600, y2: 200 };

    expect(utilities.intersects(a,b)).to.be.false;
  });

  it('should return false if horizontal bounds do not intersect', function() {
    let a = { x1: 100, y1: 100, x2: 600, y2: 200 };
    let b = { x1: 100, y1: 800, x2: 1000, y2: 200 };

    expect(utilities.intersects(a,b)).to.be.false;
  });

  it('should return true if b inside a', function() {
    let a = { x1: 100, y1: 100, x2: 600, y2: 200 };
    let b = { x1: 150, y1: 110, x2: 500, y2:180  };

    expect(utilities.intersects(a,b)).to.be.true;
  });

  it('should return true if bounds are equal', function() {
    let a = { x1: 100, y1: 100, x2: 600, y2: 200 };
    let b = { x1: 100, y1: 100, x2: 600, y2: 200 };

    expect(utilities.intersects(a,b)).to.be.true;
  });


});

