require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Methods", function() {

    /*
     * WARNING!
     * We need to make sure we we have reset the document before continuing as we
     * need to now start simulating with and without errors. This would be more
     * difficult to do if the original dialog and/or form still existed, simply
     * because things get confusing (as did in initial attempt for these tests).
     *
     * These test setup and teardown the view using beforeEach() and afterEach().
     **/

    describe("With Errors", function() {
      const FORM_ID = "activated-form-dialog-for-testing-methods-with-errors";
      const WITH_ERRORS = true;
      var createdWithErrors;

      beforeEach(function() {
        helpers.setupView(FORM_ID, WITH_ERRORS);
        createdWithErrors = helpers.createDialog(FORM_ID, {
          activatorText: c.TEXT_ACTIVATOR,
          selectorErrors: ".govuk-error-message",
          removeErrorClasses: "govuk-error-message"
        });
      });

      afterEach(function() {
        helpers.destroyDialog(createdWithErrors);
        helpers.teardownView(FORM_ID);
      });

      it("should make any found errors available public property", function() {
        expect(createdWithErrors.dialog).to.exist;
        expect(createdWithErrors.dialog.$errors).to.exist;
        expect(createdWithErrors.dialog.$errors.length).to.equal(1);
        expect(createdWithErrors.dialog.$errors.eq(0).text()).to.equal(c.TEXT_ERROR);
      });

      it("should be open on page load when errors are present", function() {
        expect(createdWithErrors.dialog.$errors.length).to.equal(1);

        expect(createdWithErrors.dialog.$container).to.exist;
        expect(createdWithErrors.dialog.$container.length).to.equal(1);
        expect(createdWithErrors.dialog.$container.get(0).style.display).to.equal("");

        // And then double check against a closed state
        createdWithErrors.dialog.$form.dialog("close");
        expect(createdWithErrors.dialog.$container.get(0).style.display).to.equal("none");
      });

      it("should clear any stored errors with clearErrors() method", function() {
        expect(createdWithErrors.dialog.$errors).to.exist;
        expect(createdWithErrors.dialog.$errors.length).to.equal(1);

        createdWithErrors.dialog.clearErrors();
        expect(createdWithErrors.dialog.$errors.length).to.equal(0);
      });

      it("should clear any stored errors when negative (cancel) button is clicked", function() {
        createdWithErrors.dialog.open();

        expect(createdWithErrors.dialog.$errors).to.exist;
        expect(createdWithErrors.dialog.$errors.length).to.equal(1);

        createdWithErrors.dialog.close();
        expect(createdWithErrors.dialog.$errors.length).to.equal(0);
      });

      it("should clear any stored errors when negative (cancel) button is clicked", function() {
        var $buttons = createdWithErrors.dialog.$container.find(".ui-dialog-buttonset button");

        expect($buttons.length).to.equal(2);
        createdWithErrors.dialog.open();

        expect(createdWithErrors.dialog.$errors).to.exist;
        expect(createdWithErrors.dialog.$errors.length).to.equal(1);

        $buttons.eq(1).click();
        expect(createdWithErrors.dialog.$errors.length).to.equal(0);
      });
    });

    describe("Without Errors", function() {
      const FORM_ID = "activated-form-dialog-for-testing-methods-without-errors";
      const WITH_ERRORS = false;
      var createdWithoutErrors;

      beforeEach(function() {
        helpers.setupView(FORM_ID, WITH_ERRORS);
        createdWithoutErrors = helpers.createDialog(FORM_ID, {
          activatorText: c.TEXT_ACTIVATOR
        });
      });

      afterEach(function() {
        helpers.destroyDialog(createdWithoutErrors);
        helpers.teardownView(FORM_ID);
      });

      it("should be closed on page load when no errors are present", function() {
        expect(createdWithoutErrors.dialog.$errors).to.exist;
        expect(createdWithoutErrors.dialog.$errors.length).to.equal(0);

        expect(createdWithoutErrors.dialog.$container).to.exist;
        expect(createdWithoutErrors.dialog.$container.length).to.equal(1);
        expect(createdWithoutErrors.dialog.$container.get(0).style.display).to.equal("none");

        // Now open it to prove test was correct.
        createdWithoutErrors.dialog.open();
        expect(createdWithoutErrors.dialog.$container.get(0).style.display).to.equal("");
      });
    });

  });
});
