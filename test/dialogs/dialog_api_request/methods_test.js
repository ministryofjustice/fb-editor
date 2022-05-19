require('../../setup');

describe("DialogApiRequest", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Methods", function() {
    // Note: Due to component makeup, the component is actually the
    // parent/container element to original target $node.
    var created;

    before(function(done) {
      var response = `<div class="component component-dialog" id="` + c.COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                      </div>`;

      helpers.setupView();
      created = helpers.createDialog(response, done);
    });

    after(function() {
      helpers.teardownView();
      created.$node.remove();
      created = {};
    });

    it("should close the dialog", function() {
      expect(created.dialog.$node.dialog("isOpen")).to.be.true;
      expect(created.dialog.state).to.equal("open");

      created.dialog.close();
      expect(created.dialog.$node.dialog("isOpen")).to.be.false;
      expect(created.dialog.state).to.equal("closed");
    });

    it("should open the dialog", function() {
      expect(created.dialog.$node.dialog("isOpen")).to.be.false;
      expect(created.dialog.state).to.equal("closed");

      created.dialog.open();
      expect(created.dialog.$node.dialog("isOpen")).to.be.true;
      expect(created.dialog.state).to.equal("open");
    });

    it("should close dialog using standard close button", function() {
      var $close = created.dialog.$container.find(".ui-dialog-titlebar-close");

      created.dialog.open();
      expect(created.dialog.$node.dialog("isOpen")).to.be.true;
      expect(created.dialog.state).to.equal("open");

      $close.click();
      expect(created.dialog.$node.dialog("isOpen")).to.be.false;
      expect(created.dialog.state).to.equal("closed");
    });

    describe("using generated buttons", function() {
      it("should close dialog using found generated 'cancel' button", function() {
        var $buttons = created.dialog.$container.find("button");

        created.dialog.open();
        expect(created.dialog.$node.dialog("isOpen")).to.be.true;
        expect(created.dialog.state).to.equal("open");

        $buttons.last().click();
        expect(created.dialog.$node.dialog("isOpen")).to.be.false;
        expect(created.dialog.state).to.equal("closed");
      });
    });

    describe("using template buttons", function() {
      const COMPONENT_ID = "dialog-api-request-methods-test-without-buttons";
      const CLASSNAME_BUTTON_TEMPLATE = "dialog-api-request-methods-test-without-buttons-button-template";
      var createdWithoutButtons;

      before(function(done) {
        var response = `<div class="component component-dialog" id="` + COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                        <button class="` + CLASSNAME_BUTTON_TEMPLATE + `">Text for template button</button>
                      </div>`;

        helpers.setupView();
        createdWithoutButtons = helpers.createDialog(response, done, {
          closeOnClickSelector: "." + CLASSNAME_BUTTON_TEMPLATE
        });
      });

      after(function() {
        helpers.teardownView();
        createdWithoutButtons.$node.remove();
        createdWithoutButtons = null;
      });

      it("should close dialog using found config.closeOnClickSelector elements", function() {
        var dialog = createdWithoutButtons.dialog;
        var $button = dialog.$container.find("." + CLASSNAME_BUTTON_TEMPLATE);

        dialog.open();
        expect(dialog.$node.dialog("isOpen")).to.be.true;
        expect(dialog.state).to.equal("open");

        $button.click();
        expect(dialog.$node.dialog("isOpen")).to.be.false;
        expect(dialog.state).to.equal("closed");
      });
    });

  });
});
