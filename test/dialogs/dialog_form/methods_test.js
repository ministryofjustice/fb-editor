require('../../setup');

describe("FormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-form-methods-test";

  describe("Methods", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(COMPONENT_ID, true);
      created = helpers.createDialog(COMPONENT_ID, {
        selectorErrors: "." + c.CLASSNAME_ERROR_MESSAGE,
        removeErrorClasses: c.CLASSNAME_ERROR_DIALOG + " " + c.CLASSNAME_ERROR_MESSAGE
      });
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    /* TEST METHOD: open()
     **/
    it("should open the dialog", function() {
      var $container = created.$node.parents("[role=dialog]");

      // should be closed by default
      expect($container.css("display")).to.equal("none");

      // now test open()
      created.dialog.open();
      expect($container.css("display")).to.not.equal("none");
    });


    /* TEST METHOD: close()
     **/
    it("should close the dialog", function() {
      var $container = created.$node.parents("[role=dialog]");

      // First open and check.
      created.dialog.open();
      expect($container.css("display")).to.not.equal("none");

      // Then see if close() properly changes the CSS value
      created.dialog.close();
      expect($container.css("display")).to.equal("none");
    });


    /* TEST METHOD: isOpen()
     **/
    it("should report false when dialog is closed", function() {
      var $container = created.$node.parents("[role=dialog]");

      // First try to make sure it's open
      created.dialog.close();
      expect($container.css("display")).to.equal("none");

      // Then test the method
      expect(created.dialog.isOpen()).to.be.false;
    });

    it("should report true when dialog is open", function() {
      var $container = created.$node.parents("[role=dialog]");

      // First try to make sure it's open
      created.dialog.open();
      expect($container.css("display")).to.not.equal("none");

      // Then test the method
      expect(created.dialog.isOpen()).to.be.true;
    });


    /* TEST METHOD: clearErrors()
     **/
    it("should clear the error markup", function() {
      // Make sure we have error markup present
      expect(created.$node.find("." + c.CLASSNAME_ERROR_DIALOG).length).to.equal(1);
      expect(created.$node.find("." + c.CLASSNAME_ERROR_MESSAGE).length).to.equal(1);

      // Now clear the error markup and retest
      created.dialog.clearErrors();
      expect(created.$node.find("." + c.CLASSNAME_ERROR_DIALOG).length).to.equal(0);
      expect(created.$node.find("." + c.CLASSNAME_ERROR_MESSAGE).length).to.equal(0);
    });

    it("should clear the dialog.$errors collection", function() {
      // Make sure dialog has errors
      expect(created.dialog.$errors.length).to.equal(1);

      // Clear error and retest
      created.dialog.clearErrors();
      expect(created.dialog.$errors.length).to.equal(0);
    });

  });
});
