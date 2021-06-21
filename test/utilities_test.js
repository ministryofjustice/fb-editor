const utilities = require('../app/javascript/src/utilities.js');
const assert = require('chai').assert;
const jsdom = require("jsdom");
const jquery = require('jquery');
const { JSDOM } = jsdom;


describe('Utilities', function () {
  before(function() {
    return JSDOM.fromFile('./test/templates/test.html')
      .then((dom) => {
        global.window = dom.window;
        global.document = window.document;
        $ = global.jQuery = require( 'jquery' )( window );
        global.$ = jquery(window);
      });
  });


  describe('mergeObjects', function() {
    it('should merge object a into object b', function() {
      var a = {
        something: 'here'
      }

      var b = {
        another: 'thing'
      }

      assert.deepEqual({
        something: 'here',
        another: 'thing'
      }, utilities.mergeObjects(a, b));
    });
  });

  describe('createElement', function() {
    it('should create a new DOM node', function() {
      var node = utilities.createElement('p', 'Some text here', ['classname1', 'classname2']);
      var paragraphs = document.getElementsByTagName('p');

      assert.equal(paragraphs.length, 2);
      assert.equal(paragraphs[1].firstChild.nodeValue, 'Some text here');
      assert.include(paragraphs[1].className, ['classname1', 'classname2']);
    });
  });


/*
  mergeObjects()
  createElement()
safelyActivateFunction()
isFunction()
uniqueString()
findFragmentIdentifier()
meta()
post()
updateHiddenInputOnForm()
property()
*/









});
