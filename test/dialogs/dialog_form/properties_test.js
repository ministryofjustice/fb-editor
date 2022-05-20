require('../../setup');

describe("FormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-form-properties-test";

  describe("Properties", function() {
    var created;
    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createDialog(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });


    it("should make the instance available as data on the $node", function() {
      expect(created.$node.data("instance")).to.equal(created.dialog);
    });

    it("should make the $node public", function() {
      expect(created.dialog.$node).to.exist;
      expect(created.dialog.$node.length).to.equal(1);
      expect(created.dialog.$node.get(0)).to.equal(created.$node.get(0));
    });

    it("should make the $container public", function() {
      expect(created.dialog.$container).to.exist;
      expect(created.dialog.$container.length).to.equal(1);
      expect(created.dialog.$container.get(0).tagName.toLowerCase()).to.equal("div");
    });

    it("should make the $form public", function() {
      expect(created.dialog.$form).to.exist;
      expect(created.dialog.$form.length).to.equal(1);
      expect(created.dialog.$form.get(0).tagName.toLowerCase()).to.equal("form");
      expect(created.dialog.$form.get(0)).to.equal(created.$node.find("form").get(0));
    });

    it("should make the (empty collection) $errors public", function() {
      expect(created.dialog.$errors).to.exist;
      expect(created.dialog.$errors.length).to.equal(0);
    });


    describe("With errors", function() {
      const COMPONENT_ID_WITH_ERRORS = "dialog-form-properties-test-with-errors";
      var createdWithErrors;

      before(function() {
        helpers.setupView(COMPONENT_ID_WITH_ERRORS, true);
        createdWithErrors = helpers.createDialog(COMPONENT_ID_WITH_ERRORS, {
          selectorErrors: "." + c.CLASSNAME_ERROR_MESSAGE,
          removeErrorClasses: c.CLASSNAME_ERROR_DIALOG + " " + c.CLASSNAME_ERROR_MESSAGE
        });
      });

      after(function() {
        helpers.teardownView(COMPONENT_ID_WITH_ERRORS);
        createdWithErrors = {};
      });


      it("should make the $errors public", function() {
        expect(createdWithErrors.dialog.$errors).to.exist;
        expect(createdWithErrors.dialog.$errors.length).to.equal(1);
      });
    });

  });
});
