require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.post', function() {
  it('should turn a delete link into form submit', function() {
    var url = 'http://localhost/fake/url/123';
    utilities.post(url, {
      testing: 'something'
    });

    expect($('form[action=\'' + url + '\']').data('params')).to.include('testing=something');
  });
});
