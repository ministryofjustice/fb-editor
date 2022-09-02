require('../../setup');
const GlobalHelpers = require("../../helpers.js");

describe("DialogApiRequest", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Component", function() {
    // Note: Due to component makeup, the component is actually the
    // parent/container element to original target $node.
    var created;
    var server;

    beforeEach(function() {
      var response = `<div class="component component-dialog" id="` + c.COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                      </div>`;

      server = GlobalHelpers.createServer();
      created = helpers.createDialog(response, server);
    });

    afterEach(function() {
      server.restore();
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
      expect($container.hasClass(c.CLASSNAME_1)).to.be.true;
      expect($container.hasClass(c.CLASSNAME_2)).to.be.true;
    });

    describe("using generted buttons", function() {
      it("should use config.buttons when not using config.closeOnClickSelector", function() {
        var $dialog = $("#" + c.COMPONENT_ID);
        var $container = $dialog.parent('[role=dialog]');
        var $buttonOk = helpers.findButtonByText($container, c.TEXT_BUTTON_OK);
        var $buttonCancel = helpers.findButtonByText($container, c.TEXT_BUTTON_CANCEL);
        var $buttons = $container.find("button"); // Includes 'Close' button
        expect($buttons.length).to.equal(3);
        expect($buttonOk.length).to.equal(1);
        expect($buttonCancel.length).to.equal(1);
      });
    });

    describe("using template buttons", function() {
      const COMPONENT_ID = "dialog-api-request-component-test-without-buttons";
      const CLASSNAME_BUTTON_TEMPLATE = "dialog-api-request-component-test-without-buttons-button-template";
      var createdWithoutButtons;
      var server;

      before(function() {
        var response = `<div class="component component-dialog" id="` + COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                        <button class="` + CLASSNAME_BUTTON_TEMPLATE + `">Text for template button</button>
                      </div>`;

        server = GlobalHelpers.createServer();
        createdWithoutButtons = helpers.createDialog(response, server, {
          closeOnClickSelector: "." + CLASSNAME_BUTTON_TEMPLATE
        });
      });

      after(function() {
        server.restore();
        createdWithoutButtons.$node.remove();
        createdWithoutButtons = null;
      });

      it("should not use config.buttons when using config.closeOnClickSelector", function() {
        var $dialog = $("#" + COMPONENT_ID);
        var $container = $dialog.parent('[role=dialog]');
        var $buttonInTemplate = $container.find("." + CLASSNAME_BUTTON_TEMPLATE);
        var $buttonInConfig = helpers.findButtonByText($container, c.TEXT_BUTTON_OK);
        var $buttons = $container.find("button"); // Will include the Dialog's Close (X) button.
        expect($buttons.length).to.equal(2);
        expect($buttonInTemplate.length).to.equal(1);
        expect($buttonInConfig.length).to.equal(0);
      });
    });

  });
});
