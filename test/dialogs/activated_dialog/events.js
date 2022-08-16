require('../../setup');

describe("ActivatedDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "activated-dialog-for-testing";


  describe("Events", function() {
    var created, check;

    describe("Configured", function() {
      before(function() {
        helpers.setupView();
        created = helpers.createDialog(COMPONENT_ID, {
          onOk: function() {
            check++;
          },
          onCancel: function() {
            check++;
          }
        });
      });

      after(function() {
        helpers.teardownView();
        created.dialog.activator.$node.remove();
        created.$node.remove();
        created = {};
      });

      it("should store an onOk handler when passed in the config", function() {
        var $dialog = created.$node.parent('[role=dialog]');
        var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_OK);
        check = 1;

        // First make sure things are in order
        expect($button).to.exist;
        expect($button.length).to.equal(1);
        expect(check).to.equal(1);

        // Next activate the button and see if event triggered
        $button.click();
        expect(check).to.equal(2);
      });

      it("should store an onCancel handler when passed in the config", function() {
        var $dialog = created.$node.parent('[role=dialog]');
        var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_CANCEL);
        check = 1;

        // First make sure things are in order
        expect($button).to.exist;
        expect($button.length).to.equal(1);
        expect(check).to.equal(1);

        // Next activate the button and see if event triggered
        $button.click();
        expect(check).to.equal(2);
      });
    });


    describe("Not Configured", function() {
      before(function() {
        helpers.setupView();
        created = helpers.createDialog(COMPONENT_ID);
      });

      after(function() {
        helpers.teardownView();
        created.$node.remove();
        created = {};
      });

      it("should not cause error when OK button is clicked and no onOk handler is present", function() {
        var $dialog = created.$node.parent('[role=dialog]');
        var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_OK);
        check = 1;

        // First make sure things are in order
        expect($button).to.exist;
        expect($button.length).to.equal(1);
        expect(check).to.equal(1);

        // Next activate the button and see if event triggered
        $button.click();
        expect(check).to.equal(1);
      });

      it("should not cause error when Cancel button is clicked and no onCancel handler is present", function() {
        var $dialog = created.$node.parent('[role=dialog]');
        var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_CANCEL);
        check = 1;

        // First make sure things are in order
        expect($button).to.exist;
        expect($button.length).to.equal(1);
        expect(check).to.equal(1);

        // Next activate the button and see if event triggered
        $button.click();
        expect(check).to.equal(1);
      });
    });

  });

});
