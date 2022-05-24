require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const FORM_ID = "activated-form-dialog-for-testing-component";

  describe("Component", function() {
    var created;
    before(function() {
      helpers.setupView();
      created = helpers.createDialog(FORM_ID, {
        activatorText: c.TEXT_ACTIVATOR
      });
    });

    after(function() {
      created.dialog.activator.$node.remove();
      helpers.teardownView();
      created = {};
    });

    it("should have the basic HTML in place", function() {
      expect($("#" + FORM_ID).length).to.equal(1);
      expect($("#" + FORM_ID).parents(".ui-dialog").length).to.equal(1);
    });

    it("should have the component class name present", function() {
      expect($("#" + FORM_ID).parents("." + c.CLASSNAME_COMPONENT).length).to.equal(1);
    });

    it("should have two buttons", function() {
      var $component = $("#" + FORM_ID).parents("." + c.CLASSNAME_COMPONENT);
      var $buttons = $component.find(".ui-dialog-buttonset button");
      expect($component.length).to.equal(1);
      expect($buttons.length).to.equal(2);
    });

    it("should have ok button with template text", function() {
      var $component = $("#" + FORM_ID).parents("." + c.CLASSNAME_COMPONENT);
      var $button = helpers.findButtonByText($component, c.TEXT_BUTTON_OK);
      expect($button.length).to.equal(1);
    });

    it("should use config.cancelText as button text", function() {
      var $component = $("#" + FORM_ID).parents("." + c.CLASSNAME_COMPONENT);
      var $button = helpers.findButtonByText($component, c.TEXT_BUTTON_OK);
      
    });

    it("should use passed activator text", function() {
      var $activator = $(".DialogActivator[id^=activated-form-dialog-for-testing-component]");
      expect($activator.length).to.equal(1);
      expect($activator.text()).to.equal(c.TEXT_ACTIVATOR);
    });

    it("should apply CSS classnames passed in config", function() {
      var $container = created.$node.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_1));
      expect($container.hasClass(c.CLASSNAME_2));
    });
  });
});
