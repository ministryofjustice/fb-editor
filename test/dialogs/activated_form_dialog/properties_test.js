require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const FORM_ID = "activated-form-dialog-for-testing-properties";

  describe("Properties", function() {
    var created;
    before(function() {
      helpers.setupView();
      created = helpers.createDialog(FORM_ID, {
        activatorText: c.TEXT_ACTIVATOR
      });
    });

    after(function() {
      helpers.teardownView(FORM_ID);
      created = {};
    });

    it("should make the $node public", function() {
      var $form = $("#" + FORM_ID);
      var dialog = created.dialog;
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.get(0)).to.equal($form.get(0));
    });

    it("should make the instance available as data on the $node", function() {;
      var dialog = created.dialog;
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.data("instance")).to.eql(dialog);
    });

    it("should make the $node public as $form variable name", function() {
      var dialog = created.dialog;
      expect(dialog.$form).to.exist;
      expect(dialog.$form.length).to.equal(1);
      expect(dialog.$node.get(0)).to.equal(dialog.$form.get(0));
    });

    it("should make the activator public", function() {
      var $activator = $(".DialogActivator[id^=activated-form-dialog-for-testing-properties]");
      var dialog = created.dialog;
      expect(dialog.activator).to.exist;
      expect(dialog.activator.$node).to.exist;
      expect(dialog.activator.$node.get(0)).to.equal($activator.get(0));
    });
  });
});
