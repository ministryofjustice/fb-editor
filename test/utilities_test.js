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

  describe('isFunction', function() {
    it('should return true if type is a function', function() {
      var thisIsAFunction = function() {};
      assert.isTrue(utilities.isFunction(thisIsAFunction));
    });

    it('should return false if type is not a function', function() {
      var thisIsNotAFunction = 'I am a string';
      assert.isFalse(utilities.isFunction(thisIsNotAFunction));
    });
  });

  describe('safelyActivateFunction', function() {
    it('should fail silently when not a function', function() {
      try {
        utilities.safelyActivateFunction('I am a string');
        assert.isOk('Safely Executed');
      } catch(e) {
        if(e instanceof TypeError) {
          assert.fail('TypeError created by non-function');
        }
      }
    });

    it('should run the function passed to it without arguments', function() {
      var a = 1;
      utilities.safelyActivateFunction(function(){ a++; });
      assert.notEqual(a, 1);
      assert.equal(a, 2);
    });

    it('should run the function passed to it including arguments', function() {
      var a = 1;
      var func = function(b) {
        a = b;
      }

      utilities.safelyActivateFunction(func(3));
      assert.notEqual(a, 1);
      assert.equal(a, 3);
    });
  });

  describe('uniqueString', function() {
    it('should return a string without passed arguments', function() {
      assert.isString(utilities.uniqueString());
    });

    it('should return a string that include the passed string value', function() {
      var str = 'mystringvalue';
      assert.isString(utilities.uniqueString(str));
      assert.include(utilities.uniqueString(str), str);
    });

    it('should not return the same string value', function() {
      var str = 'mystringvalue';
      var str1 = utilities.uniqueString(str);
      var str2 = utilities.uniqueString(str);
      assert.notEqual(str1, str2);
    });
  });

  describe('findFragmentIdentifier', function() {
    it('should return the fragment identifer from passed url value', function() {
      assert.equal(utilities.findFragmentIdentifier('http://example.com/some/url#withfragment'), 'withfragment');
      assert.notEqual(utilities.findFragmentIdentifier('http://example.com/some/url#withfragment'), 'wrongfragment');
    });

    it('should return the url when no fragment identifer is found', function() {
      var url = 'http://example.com/some/url';
      assert.equal(utilities.findFragmentIdentifier(url), url);
    });
  });

  describe('meta', function() {
    it('should return the meta tag value', function() {
      var meta = document.createElement('meta');
      meta.setAttribute('name', 'mytestmetatag');
      meta.setAttribute('content', 'mytestcontentvalue');
      document.head.appendChild(meta);

      assert.equal(utilities.meta('mytestmetatag'), 'mytestcontentvalue');
    });
  });

/*
  mergeObjects()
  createElement()
  isFunction()
  safelyActivateFunction()
  uniqueString()
  findFragmentIdentifier()
  meta()
post()
updateHiddenInputOnForm()
property()
*/









});
