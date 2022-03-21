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

        // Highjack form submits to inspect data
        global.window.HTMLFormElement.prototype.submit = function() {
          var $form = $(this);
          $form.data("params", $form.serialize());
        }
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

  describe('post', function() {
    it('should turn a delete link into form submit', function() {
      var url = 'http://localhost/fake/url/123';
      utilities.post(url, {
        testing: 'something'
      });

      assert.include($('form[action=\'' + url + '\']').data('params'), 'testing=something');
    });
  });

  describe('addHiddenInputElementToForm', function() {
    before(function() {
      var $form = $('<form></form>');
      $form.attr('id', 'addHiddenInputElementToForm');
      $(document.body).append($form);
    });

    it('should add a new hidden form element to specified form if does not exist', function() {
      var $form = $('#addHiddenInputElementToForm');
      utilities.addHiddenInputElementToForm($form, 'field1', 'field-1-content');

      assert.equal($form.find('[name=\'field1\']').val(), 'field-1-content');
    });

    after(function() {
      $('#addHiddenInputElementToForm').remove();
    });
  });

  describe('updateHiddenInputOnForm', function() {
    before(function() {
      var $form = $('<form></form>');
      $form.attr('id', 'updateHiddenInputOnForm');
      $(document.body).append($form);
    });

    it('should update an existing hidden form element', function() {
      var $form1 = $('#updateHiddenInputOnForm');
      utilities.addHiddenInputElementToForm($form1, 'field2', 'field-2-content');

      assert.equal($form1.find('[name=\'field2\']').val(), 'field-2-content');

      utilities.updateHiddenInputOnForm($form1, 'field2', 'field-2-content-updated');

      assert.equal($form1.find('[name=\'field2\']').val(), 'field-2-content-updated');
    });

    after(function() {
      $('#updateHiddenInputOnForm').remove();
    });
  });

  describe('property', function() {
    it('should return the specified top level property value', function() {
      var obj1 = {
        something: {
          goes: 'here'
        }
      }

       assert.deepEqual(utilities.property(obj1, 'something'), { goes: 'here' });
    });

    it('should return the specified inner level property value', function() {
      var obj2 = {
        something: {
          goes: 'here'
        }
      }

       assert.equal(utilities.property(obj2, 'something.goes'), 'here');
    });

    it('should return the specified deep inner level property value', function() {
      var obj3 = {
        something: {
          goes: {
            here: 'inside'
          }
        }
      }
       assert.equal(utilities.property(obj3, 'something.goes.here'), 'inside');
    });
  });

  describe('isBoolean', function() {
    it('should return false if a String is checked', function() {
      assert.isFalse(utilities.isBoolean("a string"));
    });

    it('should return true if a Boolean is checked', function() {
      assert.isTrue(utilities.isBoolean(true));
    });
  });

  describe('updateDomByApiRequest', function() {
    var targetId = "update-dom-by-api-request-target-element";
    var insertId = "update-dom-by-api-request-insert-element";
    var get;

    before(function() {
      get = $.get;
      $(document.body).append("<p id=\"" + targetId + "\"></p>");
      $.get = function(urlNotNeeded, response) {
        response("<span id=\"" + insertId + "\">Luke</span>");
      }
    });

    afterEach(function() {
       $(document.body).find("#" + insertId).remove();
    });

    after(function() {
       $(document.body).find("#" + targetId).remove();
       $.get = get;
    });

    it('should place new element after target node', function() {
      var $targetNode = $(document.body).find("#" + targetId);

      // First check inserted node is not there.
      assert.isFalse($(document.body).find("#" + insertId).length > 0);

      utilities.updateDomByApiRequest("", {
        target: $targetNode,
        done: function() {
          var $insertedNode = $targetNode.find("#" + insertId);
          assert.exists($targetNode);
          assert.equal($targetNode.length, 1);
          assert.exists($insertedNode);
          assert.equal($insertedNode.length, 1);
          assert.isTrue($targetNode.find($insertedNode).length > 0);
        }
      });
    });

    it('should place new element before target node', function() {
      var $targetNode = $(document.body).find("#" + targetId);

      // First check inserted node is not there.
      assert.isFalse($(document.body).find("#" + insertId).length > 0);

      utilities.updateDomByApiRequest("", {
        type: "after",
        target: $targetNode,
        done: function() {
          var $insertedNode = $(document.body).find("#" + insertId);
          assert.exists($targetNode);
          assert.equal($targetNode.length, 1);
          assert.exists($insertedNode);
          assert.equal($insertedNode.length, 1);
          assert.isTrue($targetNode.next().is($insertedNode));
        }
      });
    });

    it('should append new element before target node', function() {
      var $targetNode = $(document.body).find("#" + targetId);

      // First check inserted node is not there.
      assert.isFalse($(document.body).find("#" + insertId).length > 0);

      utilities.updateDomByApiRequest("", {
        type: "before",
        target: $targetNode,
        done: function() {
          var $insertedNode = $(document.body).find("#" + insertId);
          assert.exists($targetNode);
          assert.equal($targetNode.length, 1);
          assert.exists($insertedNode);
          assert.equal($insertedNode.length, 1);
          assert.isTrue($targetNode.prev().is($insertedNode));
        }
      });
    });

  });

  describe('stringInject', function() {
    it('should inject matching strings', function() {
      var text = "These are not the #{noun} you are #{verb} for.";
      var words = {
        noun: "droids",
        verb: "looking"
      }

      assert.equal(utilities.stringInject(text, words), "These are not the droids you are looking for.");
    });

    it('should not inject unmated strings', function() {
      var text = "These are not the #{noun} you are #{verb} for.";
      var words = {
        noun: "droids",
        adjective: "metallic"
      }

      assert.equal(utilities.stringInject(text, words), "These are not the droids you are #{verb} for.");
    });
  });

  describe('mazWidth', function() {
    it('should return the maxWidth found in a collection', function() {
      var $item1 = $("<p id=\"test-maxwidth-item1\">width item 1");
      var $item2 = $("<p id=\"test-maxwidth-item2\">width item 2");
      var $item3 = $("<p id=\"test-maxwidth-item3\">width item 3");
      var $collection = $(); // empty jQuery collection.

      // Add some widths...
      $item1.css({ width: "300px" });
      $item2.css({ width: "500px" });
      $item3.css({ width: "400px" });

      // Stick them in the document...
      $(document.body).append($item1);
      $(document.body).append($item2);
      $(document.body).append($item3);

      // Find the items...
      $collection = $(document.body).find("#test-maxwidth-item1, #test-maxwidth-item2, #test-maxwidth-item3");

      // Check we have them and their widths are correct...
      assert.equal($collection.length, 3);
      assert.equal($collection.eq(0).width(), "300");
      assert.equal($collection.eq(1).width(), "500");
      assert.equal($collection.eq(2).width(), "400");

      // Check we can find the max width
      assert.equal(utilities.maxWidth($collection), "500");
    });
  });
});
