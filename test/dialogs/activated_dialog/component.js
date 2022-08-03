require('../../setup');

describe("ActivatedDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "activated-dialog-for-testing";


  describe("Component", function() {
    // Note: Due to component makeup, the component is actually the
    // parent/container element to original target $node.
    var created;

    before(function() {
      helpers.setupView();
      created = helpers.createDialog(COMPONENT_ID)
    });

    after(function() {
      helpers.teardownView();
      created.dialog.activator.$node.remove();
      created.$node.remove();
      created = {};
    });


    it("should have the basic HTML in place", function() {
      var $dialog = $("#" + COMPONENT_ID);
      var $container = created.$node.parent('[role=dialog]');

      expect($dialog.length).to.equal(1);
      expect($dialog.get(0).nodeName.toLowerCase()).to.equal("div");
      expect($dialog.hasClass("ui-dialog")).to.be.true;
      expect($container.get(0)).to.equal($dialog.get(0));
    });

    it("should have the component class name present", function() {
      var $container = created.$node.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

    it("should apply CSS classnames passed in config", function() {
      var $container = created.$node.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_1)).to.be.true;
      expect($container.hasClass(c.CLASSNAME_2)).to.be.true;
    });

    it("should use config.okText as button text", function() {
      var $dialog = created.$node.parent('[role=dialog]');
      var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_OK);
      expect($button).to.exist;
      expect($button.length).to.equal(1);
      expect($button.text()).to.equal(c.TEXT_BUTTON_OK);
    });

    it("should use config.cancelText as button text", function() {
      var $dialog = created.$node.parent('[role=dialog]');
      var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_CANCEL);
      expect($button).to.exist;
      expect($button.length).to.equal(1);
      expect($button.text()).to.equal(c.TEXT_BUTTON_CANCEL);
    });

    it("should make the instance available as data on the $node", function() {
      var $container = created.$node.parent('[role=dialog]');
      expect(created.$node.data("instance")).to.equal(created.dialog);
    });

    it("should make the $node public", function() {
      expect(created.dialog.$node).to.exist;
      expect(created.dialog.$node.length).to.equal(1);
      expect(created.dialog.$node.get(0)).to.equal(created.$node.get(0));
    });

    it("should make the activator public", function() {
      expect(created.dialog.activator).to.exist;
      expect(created.dialog.activator.$node).to.exist;
      expect(created.dialog.activator.$node.length).to.equal(1);
      expect(created.dialog.activator.$node.hasClass("DialogActivator")).to.be.true;
    });
  });

});
