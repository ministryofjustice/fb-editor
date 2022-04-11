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
      var $container = created.$node.parent('[role=dialog]');
      var passed = false;

      $container.find(".ui-button").each(function() {
        if($(this).text() == c.TEXT_BUTTON_OK) {
          passed = true;
          return false;
        }
      });

      expect(passed).to.be.true;
    });

    it("should use config.cancelText as button text");
    it("should make the instance available as data on the $node");
    it("should make the $node public");
    it("should make (public but indicated as) private reference to config");
    it("should make the activator public");
  });

  describe("Events", function() {
    it("should store an onOk handler when passed in the config");
    it("should store an onCancel handler when passed in the config");
  });

});
