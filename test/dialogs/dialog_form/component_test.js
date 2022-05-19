require('../../setup');

describe("FormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-form-component-test";

  describe("Component", function() {
    var created;
    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createDialog(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });


    it("should have the basic HTML in place", function() {
      var $dialog = $("#" + COMPONENT_ID);
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).nodeName.toLowerCase()).to.equal("div");
      expect(created.$node.attr("id")).to.equal(COMPONENT_ID);
      expect(created.$node.hasClass("component-dialog-form")).to.be.true;
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


    describe("With errors", function() {
      const COMPONENT_ID_WITH_ERRORS = "dialog-form-component-test-with-errors";
      var createdWithErrors;

      before(function() {
        helpers.setupView(COMPONENT_ID_WITH_ERRORS, true);
        createdWithErrors = helpers.createDialog(COMPONENT_ID_WITH_ERRORS, {
          selectorErrors: "." + c.CLASSNAME_ERROR_MESSAGE,
          removeErrorClasses: c.CLASSNAME_ERROR_DIALOG + " " + c.CLASSNAME_ERROR_MESSAGE
        });
      });

      after(function() {
        helpers.teardownView(COMPONENT_ID_WITH_ERRORS);
        createdWithErrors = {};
      });


      it("should contain error markup", function() {
        expect(createdWithErrors.$node.find("." + c.CLASSNAME_ERROR_DIALOG).length).to.equal(1);
        expect(createdWithErrors.$node.find("." + c.CLASSNAME_ERROR_MESSAGE).length).to.equal(1);
      });
    });

  });
});
