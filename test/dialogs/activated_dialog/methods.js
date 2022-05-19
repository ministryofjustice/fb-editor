require('../../setup');

describe("ActivatedDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "activated-dialog-for-testing";


  describe("Methods", function() {
    // Note: Due to component makeup, the component is actually the
    // parent/container element to original target $node.

    it("should open the dialog with public open() method", function() {
      var created = setup();
      var $dialog = $("#" + COMPONENT_ID);

      expect($dialog.css("display")).to.equal("none");

      created.dialog.open();
      expect($dialog.css("display")).to.not.equal("none");

      teardown(created);
    });

    it("should open the dialog on activator button press", function() {
      var created = setup();
      var $dialog;

      $(document.body).append(created.dialog.activator.$node);

      $dialog = $("#" + COMPONENT_ID);
      expect($dialog.css("display")).to.equal("none");

      $(".DialogActivator").click();
      expect($dialog.css("display")).to.not.equal("none");

      teardown(created);
    });

    it("should be closed on page load when config.autoOpen is false", function() {
      var created = setup();
      var $dialog = $("#" + COMPONENT_ID);

      expect($dialog.css("display")).to.equal("none");
      teardown(created);
    });

    it("should be open on page load when config.autoOpen is true", function() {
      var created = setup({ autoOpen: true });
      var $dialog = $("#" + COMPONENT_ID);

      expect($dialog.css("display")).to.not.equal("none");
      teardown(created);
    });

    it("should close the dialog on negative button press", function() {
       var created = setup();
       var $dialog = $("#" + COMPONENT_ID);

       expect($dialog.css("display")).to.equal("none");
       created.dialog.open();
       expect($dialog.css("display")).to.not.equal("none");

       helpers.findButtonByText($dialog, c.TEXT_BUTTON_CANCEL).click();
       expect($dialog.css("display")).to.equal("none");
    });
  });

  function setup(conf) {
    helpers.setupView();
    return helpers.createDialog(COMPONENT_ID, conf || {});
  }

  function teardown(created) {
    helpers.teardownView();
    created.$node.remove();
    created = {};
  }

});
