require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Component", function() {
    const FORM_ID = "activated-form-dialog-for-testing-component";
    var created;

    before(function() {
      helpers.setupView(FORM_ID);
      created = helpers.createDialog(FORM_ID, {
        activatorText: c.TEXT_ACTIVATOR
      });
    });

    after(function() {
      helpers.teardownView(FORM_ID);
      helpers.destroyDialog(created);
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

    it("should apply CSS classnames passed in config", function() {
      var $container = created.$node.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_1));
      expect($container.hasClass(c.CLASSNAME_2));
    });
  });


  describe.only("Component with created Activator", function() {
    const FORM_ID = "activated-form-dialog-for-testing-component-generated-activator";
    var created;

    before(function() {
      helpers.setupView(FORM_ID);
      created = helpers.createDialog(FORM_ID, {
        activatorText: c.TEXT_ACTIVATOR
      });
    });

    after(function() {
      helpers.teardownView(FORM_ID);
      helpers.destroyDialog(created);
    });

    it("should use passed activator text", function() {
      var $activator = $(".DialogActivator[id^=" + FORM_ID + "]");
      expect($activator.length).to.equal(1);
      expect($activator.text()).to.equal(c.TEXT_ACTIVATOR);
    });

    it("should place any created Activator after the target form ($node)", function() {
      var $dialog = created.$node.parent(".ActivatedFormDialog");
      var $activator = $(".DialogActivator[id^=" + FORM_ID + "]");
      var $originalFormParent = $("#" + (FORM_ID + c.PARENT_ID_ADDITION));
       expect($activator.length).to.equal(1);
       expect($originalFormParent.length).to.equal(1);
       expect($activator.parent().get(0)).to.equal($originalFormParent.get(0));
       expect($dialog.parent().get(0)).to.not.equal($originalFormParent.get(0));
    });
  });
});
