require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const FORM_ID = "dialog-for-testing-without-error";

  describe("With error", function() {
    var created;
    before(function() {
      helpers.setupView();
      created = helpers.createDialog(FORM_ID, {
        activatorText: c.TEXT_ACTIVATOR
      });
    });

    after(function() {
      helpers.teardownView();
      created.dialog.activator.$node.remove();
      created.dialog.$container.remove();
      created = {};
    });


    it("should be closed on page load when no errors are present", function() {
      expect(created.dialog.$errors).to.exist;
      expect(created.dialog.$errors.length).to.equal(0);

      expect(created.dialog.$container).to.exist;
      expect(created.dialog.$container.length).to.equal(1);
      expect(created.dialog.$container.get(0).style.display).to.equal("none");

      // Now open it to prove test was correct.
      created.dialog.open();
      expect(created.dialog.$container.get(0).style.display).to.equal("");
    });
  });
});
