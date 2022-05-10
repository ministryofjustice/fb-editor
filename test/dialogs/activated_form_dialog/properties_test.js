require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const FORM_ID = "dialog-for-testing-properties";

  describe("Properties", function() {
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


    it("should have the basic HTML in place", function() {
      expect($("#" + FORM_ID).length).to.equal(1);
      expect($("#" + FORM_ID).parents(".ui-dialog").length).to.equal(1);
    });

    it("should make the $node public", function() {
      var $form = $("#" + FORM_ID);
      expect(created.dialog.$node).to.exist;
      expect(created.dialog.$node.length).to.equal(1);
      expect(created.dialog.$node.get(0)).to.equal($form.get(0));
    });

    it("should make the instance available as data on the $node", function() {;
      expect(created.dialog.$node).to.exist;
      expect(created.dialog.$node.length).to.equal(1);
      expect(created.dialog.$node.data("instance")).to.eql(created.dialog);
    });

    it("should make the $node public as $form variable name", function() {
      expect(created.dialog.$form).to.exist;
      expect(created.dialog.$form.length).to.equal(1);
      expect(created.dialog.$node.get(0)).to.equal(created.dialog.$form.get(0));
    });

    it("should make the activator public", function() {
      var $activator = $("." + c.CLASSNAME_ACTIVATOR);
      expect(created.dialog.activator).to.exist;
      expect(created.dialog.activator.$node).to.exist;
      expect(created.dialog.activator.$node.get(0)).to.equal($activator.get(0));
    });

  });
});
