const utilities = require('../app/javascript/src/utilities.js');
const assert = require('chai').assert;
const jsdom = require("jsdom");
const jquery = require('jquery');
const { JSDOM } = jsdom;


describe('Utilities', function () {
  before(function() {
    return JSDOM.fromFile('./test/templates/govuk/radios.html')
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
