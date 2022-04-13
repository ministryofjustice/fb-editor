require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.meta', function() {
  it('should return the meta tag value', function() {
    var meta = document.createElement('meta');
    meta.setAttribute('name', 'mytestmetatag');
    meta.setAttribute('content', 'mytestcontentvalue');
    document.head.appendChild(meta);

    expect(utilities.meta('mytestmetatag')).to.equal('mytestcontentvalue');
  });
});
