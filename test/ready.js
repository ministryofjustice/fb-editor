const expect = require('chai').expect;
const jsdom = require("jsdom");
const jquery = require('jquery');
const { JSDOM } = jsdom;

const utilities = require('../app/javascript/src/utilities.js');

describe('Test', function () {
  before(function() {
    return JSDOM.fromFile('./test/templates/test.html')
      .then((dom) => {
        global.window = dom.window;
        global.document = window.document;
        global.jQuery = require( 'jquery' )( window );
        global.$ = jquery(window);
        require('jquery-ui/ui/widget');
        require('jquery-ui/ui/widgets/dialog');
      });
  });


  describe('templates', function() {
    it('should have a window available', function() {
      expect(typeof window).to.equal(typeof (new Object));
    });

    it('should have a document available', function() {
      expect(typeof document).to.equal(typeof (new Object));
    });

    it('should have a viable DOM', function() {
      expect(document.title).to.equal("Testing HTML document");
    });
  });

  describe('script', function() {
    it('should have loaded jQuery', function() {
      expect(typeof jQuery.fn).to.equal("object");
      expect(typeof jQuery.fn.jquery).to.equal("string");
    });

    it('should have jQuery attached to window', function() {
      expect(typeof window.jQuery).to.equal("function");
    });

    it('should find elements with jQuery', function() {
      expect($(document).find("h1").text()).to.equal("Test HTML document");
    });

    it('should load jQueryUI', function() {
      expect(typeof jQuery.ui).to.equal("object");
    });
  });

  describe('resources', function() {
    it('should be loaded when required', function() {
      expect(typeof utilities.mergeObjects).to.equal(typeof Function);
    });
  });

});
