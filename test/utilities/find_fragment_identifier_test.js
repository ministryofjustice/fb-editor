require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.findFragmentIdentifier', function() {
  it('should return the fragment identifer from passed url value', function() {
    expect(utilities.findFragmentIdentifier('http://example.com/some/url#withfragment')).to.equal('withfragment');
    expect(utilities.findFragmentIdentifier('http://example.com/some/url#withfragment')).to.not.equal('wrongfragment');
  });

  it('should return the url when no fragment identifer is found', function() {
    var url = 'http://example.com/some/url';
    expect(utilities.findFragmentIdentifier(url)).to.equal(url);
  });
});
