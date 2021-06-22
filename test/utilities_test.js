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

  describe('addHiddenInpuElementToForm', function() {
    before(function() {
      var $form = $('<form></form>');
      $form.attr('id', 'addHiddenInpuElementToForm');
      $(document.body).append($form);
    });

    it('should add a new hidden form element to specified form if does not exist', function() {
      var $form = $('#addHiddenInpuElementToForm');
      utilities.addHiddenInpuElementToForm($form, 'field1', 'field-1-content');

      assert.equal($form.find('[name=\'field1\']').val(), 'field-1-content');
    });

    after(function() {
      $('#addHiddenInpuElementToForm').remove();
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
      utilities.addHiddenInpuElementToForm($form1, 'field2', 'field-2-content');

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

/*
  mergeObjects()
  createElement()
  isFunction()
  safelyActivateFunction()
  uniqueString()
  findFragmentIdentifier()
  meta()
  post()
  addHiddenInputOnForm()
  updateHiddenInputOnForm()
  property()
*/









});
