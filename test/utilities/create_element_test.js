require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');

describe('utilities.createElement', function () {

  it('should create a new DOM node', function() {
    const UNIQUE_CLASSNAME = "utilities-create-element-method-injected-item";
    const TEXT = "utilities createElement injected paragraph";
    var node = utilities.createElement('p', TEXT, "classname1 " + UNIQUE_CLASSNAME);
    var paragraphs = document.getElementsByClassName(UNIQUE_CLASSNAME);
    var classnames;

    expect(paragraphs.length).to.equal(1);
    expect(paragraphs[0].firstChild.nodeValue).to.equal(TEXT);

    expect(paragraphs[0].className).to.include('classname1');
    expect(paragraphs[0].className).to.include(UNIQUE_CLASSNAME);
  });

});
