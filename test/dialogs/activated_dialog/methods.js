require('../../setup');

describe("ActivatedDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-for-testing";


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

    it("should be open on page load when config.autoOpen is true");
    it("should close the dialog on negative button press");
  });

  function setup() {
    helpers.setupView();
    return helpers.createDialog(COMPONENT_ID);
  }

  function teardown(created) {
    helpers.teardownView();
    created.$node.remove();
    created = {};
  }

});
