require('../../setup');

describe("ActivatedDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-for-testing";


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
      expect($container.hasClass(c.CLASSNAME_1));
      expect($container.hasClass(c.CLASSNAME_2));
    });

    it("should use config.okText as button text", function() {
      expect(helpers.buttonHasText(created.$node, c.TEXT_BUTTON_OK)).to.be.true;
    });

    it("should use config.cancelText as button text", function() {
      expect(helpers.buttonHasText(created.$node, c.TEXT_BUTTON_CANCEL)).to.be.true;
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

    it("should make the activator public");
  });

  describe("Events", function() {
    it("should store an onOk handler when passed in the config");
    it("should store an onCancel handler when passed in the config");
  });

});
