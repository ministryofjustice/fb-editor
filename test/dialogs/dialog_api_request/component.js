require('../../setup');

describe("DialogApiRequest", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CLASSNAME_BUTTON_TEMPLATE = "button-in-template";

  describe("Component without buttons", function() {
    // Note: Due to component makeup, the component is actually the
    // parent/container element to original target $node.
    var created;

    before(function(done) {
      var response = `<div class="component component-dialog" id="` + c.COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                        <button class="` + CLASSNAME_BUTTON_TEMPLATE + `">Text in template button</button>
                      </div>`;

      helpers.setupView();
      created = helpers.createDialog(response, done, {
        closeOnClickSelector: "." + CLASSNAME_BUTTON_TEMPLATE
      });
    });

    after(function() {
      helpers.teardownView();
      created.$node.remove();
      created = {};
    });

    it("should have the basic HTML in place", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      var $container = $dialog.parent('[role=dialog]');

      expect($dialog.length).to.equal(1);
      expect($dialog.get(0).nodeName.toLowerCase()).to.equal("div");
      expect($dialog.hasClass("component-dialog")).to.be.true;
    });

    it("should have the component class name present", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      var $container = $dialog.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

    it("should apply CSS classnames passed in config", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      var $container = $dialog.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_1));
      expect($container.hasClass(c.CLASSNAME_2));
    });

    it("should make the $node public", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      expect(created.dialog.$node).to.exist;
      expect(created.dialog.$node.length).to.equal(1);
      expect(created.dialog.$node.get(0)).to.equal($dialog.get(0));
    });

    it.only("should make the instance available as data on the $node", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      expect($dialog.data("instance")).to.equal(created.dialog);
    });

    it("should not use config.buttons when using config.closeOnClickSelector", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      var $buttonInTemplate = $dialog.find("." + CLASSNAME_BUTTON_TEMPLATE);
      var $buttonInConfig = helpers.findButtonByText($dialog, c.TEXT_BUTTON_OK);
      var $buttons = $dialog.find("button");
      expect($buttons.length).to.equal(1);
      expect($buttonInTemplate.length).to.equal(1);
      expect($buttonInConfig.length).to.equal(0);
    });

    it("should make the activator public", function() {
      expect(created.dialog.activator).to.exist;
      expect(created.dialog.activator.$node).to.exist;
      expect(created.dialog.activator.$node.length).to.equal(1);
      expect(created.dialog.activator.$node.hasClass("DialogActivator")).to.be.true;
    });
  });

});
