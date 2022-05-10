require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const FORM_ID = "dialog-for-testing-with-error";

  describe("With error", function() {
    var created;
    beforeEach(function() {
      $(document.body).append(`<script type="text/html" data-component-template="ActivatedFormDialog">
                                 <form action="/" method="post">
                                   <span class="govuk-error-message">This is an error</span>
                                   <input type="text" value="some value here" name="some_input" />
                                   <input type="submit" value="` + c.TEXT_BUTTON_OK + `" />
                                 </form>
                               </script>`);

      created = helpers.createDialog(FORM_ID, {
        activatorText: c.TEXT_ACTIVATOR,
        selectorErrors: ".govuk-error-message",
        removeErrorClasses: "govuk-error-message"
      });
    });

    afterEach(function() {
      helpers.teardownView();
      created.dialog.activator.$node.remove();
      created.dialog.$container.remove();
      created = {};
    });


    it("should make any found errors available as public property", function() {
      expect(created.dialog).to.exist;
      expect(created.dialog.$errors).to.exist;
      expect(created.dialog.$errors.length).to.equal(1);
      expect(created.dialog.$errors.eq(0).text()).to.equal("This is an error");
    });

    it("should be open on page load when errors are present", function() {
      expect(created.dialog.$errors.length).to.equal(1);

      expect(created.dialog.$container).to.exist;
      expect(created.dialog.$container.length).to.equal(1);
      expect(created.dialog.$container.get(0).style.display).to.equal("");

      // And then double check against a closed state
      created.dialog.$form.dialog("close");
      expect(created.dialog.$container.get(0).style.display).to.equal("none");
    });

    it("should clear any stored errors with clearErrors() method", function() {
      expect(created.dialog.$errors).to.exist;
      expect(created.dialog.$errors.length).to.equal(1);

      created.dialog.clearErrors();
      expect(created.dialog.$errors.length).to.equal(0);
    });

    it("should clear any stored errors when negative (cancel) button is clicked", function() {
      created.dialog.open();

      expect(created.dialog.$errors).to.exist;
      expect(created.dialog.$errors.length).to.equal(1);

      created.dialog.close();
      expect(created.dialog.$errors.length).to.equal(0);
    });

    it("should clear any stored errors when negative (cancel) button is clicked", function() {
      var $buttons = created.dialog.$container.find(".ui-dialog-buttonset button");

      expect($buttons.length).to.equal(2);
      created.dialog.open();

      expect(created.dialog.$errors).to.exist;
      expect(created.dialog.$errors.length).to.equal(1);

      $buttons.eq(1).click();
      expect(created.dialog.$errors.length).to.equal(0);
    });
  });
});
