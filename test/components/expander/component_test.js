require('../../setup');

describe("Expander", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "expander-for-testing-component";

  describe("Component", function() {
    var created;
    before(function() {
      helpers.setupView();
      created = helpers.createExpander(COMPONENT_ID);
    });

    after(function() {
      $("#" + COMPONENT_ID).remove();
      created = {};
    });


    it("should have the basic HTML in place", function() {
      var $content = $('#' + COMPONENT_ID);

      expect($content.length).to.equal(1);
      expect($content.find("h2").length).equal(1);
      expect($content.find("p").length).equal(3);
    });

    it("should have the expander class name present", function() {
      expect($('#' + COMPONENT_ID).find("div").get(0).className).to.equal(c.CLASSNAME_COMPONENT);
    });

    it("should enhance with a button", function() {
      var $button = $('#' + COMPONENT_ID).find('button');

      expect($button.length).to.equal(1);
      expect($button.get(0).className).to.equal(c.CLASSNAME_ACTIVATOR);
    });

    it("should add an ID to the $node and aria-controls to the button", function() {
      var $content = $('#' + COMPONENT_ID);
      var $button = $content.find('button');

      expect($content.find("." + c.CLASSNAME_COMPONENT).attr('id')).to.include('Expander');
      expect($button.attr('aria-controls')).to.include('Expander');
      expect($content.find("." + c.CLASSNAME_COMPONENT).attr('id')).to.equal($button.attr('aria-controls'));
    });
  });
});
