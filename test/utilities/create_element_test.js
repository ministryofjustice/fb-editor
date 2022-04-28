require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');

describe('utilities.createElement', function () {

  it('should create a new DOM node', function() {
    var node = utilities.createElement('p', 'Some text here', ['classname1', 'classname2']);
    var paragraphs = document.getElementsByTagName('p');
    var classnames;

    expect(paragraphs.length).to.equal(2);
    expect(paragraphs[1].firstChild.nodeValue).to.equal('Some text here');

    classnames = paragraphs[1].className.split(",");
    expect(classnames).to.include('classname1');
    expect(classnames).to.include('classname2');
  });

});
