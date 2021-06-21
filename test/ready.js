const utilities = require('../app/javascript/src/utilities.js');
const expect = require('chai').expect;
const jsdom = require("jsdom");
const jquery = require('jquery');
const { JSDOM } = jsdom;


describe('Test', function () {
  before(function() {
    return JSDOM.fromFile('./test/templates/test.html')
      .then((dom) => {
        global.window = dom.window;
        global.document = window.document;
        global.jQuery = require( 'jquery' )( window );
        global.$ = jquery(window);
      });
  });


  describe('templates', function() {
    it('should be available when called', function() {
      expect(document.title).to.equal("Testing HTML document");
    });

    it('should have ability to load jQuery', function() {
      expect($(document).find("h1").text()).to.equal("Test HTML document");
    });
  });

  describe('resources', function() {
    it('should be loaded when required', function() {
      expect(typeof utilities.mergeObjects).to.equal(typeof Function);
    });
  });

});
