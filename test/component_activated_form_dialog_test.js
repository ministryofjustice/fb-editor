require('./setup');

describe("ActivatedFormDialog", function() {

  const ActivatedFormDialog = require('../app/javascript/src/component_activated_form_dialog');
  const COMPONENT_CLASS_NAME = "ActivatedFormDialog";
  const SUBMIT_BUTTON_ID = "submit-test-id";
  const FORM_ID = "form-test-id";
  const TEXT_CANCEL = "Dialog says Cancel";
  var dialog;

  before(function() {
    // jQuyery is present in document because the
    // components use it, so we can use it here.

    var $form = $(`<form action="/" method="post">
                       <input type="text" value="some value here" name="some_input" />
                       <input type="submit" value="Submit button" />
                     </form>`);

    var $submit = $form.find("[type=submit]");

    $submit.attr("id", SUBMIT_BUTTON_ID);
    $form.attr("id", FORM_ID);
    $(document.body).append($form);
    dialog = new ActivatedFormDialog($form, {
      cancelText: TEXT_CANCEL,
      okText: $submit.val(),
      $activator: $submit
    });
  });

  describe("HTML", function() {
    it("should have the basic HTML in place", function() {
      expect($("#" + FORM_ID).length).to.equal(1);
    });

    it("should have the component class name present", function() {
      expect(dialog.$container.hasClass(COMPONENT_CLASS_NAME)).to.be.true;
    });

    it("should have two buttons", function() {
       var $buttons = dialog.$container.find(".ui-dialog-buttonset button");
       expect($buttons.length).to.equal(2);
    });
  });

  describe("Config", function() {
    it("should use passed activator text as affirmative button text", function() {
       var $buttons = dialog.$container.find(".ui-dialog-buttonset button");
       var $submit = $("#" + SUBMIT_BUTTON_ID);
       expect($buttons.eq(0).text()).to.equal($submit.val());
    });

    it("should use config.cancelText as button text", function() {
       var $buttons = dialog.$container.find(".ui-dialog-buttonset button");
       expect($buttons.eq(1).text()).to.equal(TEXT_CANCEL);
    });
  });

  describe("Properties", function() {
    it("should make the $node public", function() {
      var $form = $("#" + FORM_ID);
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.get(0)).to.equal($form.get(0));
    });

    it("should make the instance available as data on the $node", function() {;
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.data("instance")).to.eql(dialog);
    });

    it("should make the $node public as $form variable name", function() {
      expect(dialog.$form).to.exist;
      expect(dialog.$form.length).to.equal(1);
      expect(dialog.$node.get(0)).to.equal(dialog.$form.get(0));
    });

    it("should make the activator public", function() {
      var $submit = $("#" + SUBMIT_BUTTON_ID);
      expect(dialog.activator).to.exist;
      expect(dialog.activator.$node).to.exist;
      expect(dialog.activator.$node.get(0)).to.equal($submit.get(0));
    });
  });

  describe("Open", function() {
    it("should open the dialog with public open() method", function() {
      var $form = $("#" + FORM_ID);

      // Make sure it's closed
      $form.dialog("close");
      expect(dialog.$container).to.exist;
      expect(dialog.$container.length).to.equal(1);
      expect(dialog.$container.get(0).style.display).to.equal("none");

      dialog.open();
      expect(dialog.$container.get(0).style.display).to.equal("");
    });

    it("should open the dialog on activator button press", function() {
      var $form = $("#" + FORM_ID);

      // Make sure it's closed
      $form.dialog("close");
      expect(dialog.$container).to.exist;
      expect(dialog.$container.length).to.equal(1);
      expect(dialog.$container.get(0).style.display).to.equal("none");

      dialog.activator.$node.click();
      expect(dialog.$container.get(0).style.display).to.equal("");
    });
  });

  describe("Submit", function() {
    it("should submit the form when OK button is clicked", function() {
      var $form = $("#" + FORM_ID);
      var $buttons = dialog.$container.find(".ui-dialog-buttonset button");
      var value = 1;

      // Prevent the form from submitting but manipulate
      // scoped variable to make sure that submit event ran.
      $form.on("submit", function(e) {
        e.preventDefault();
        value++;
      });

      expect(value).to.equal(1);
      expect($buttons).to.exist;
      expect($buttons.length).to.equal(2);

      $buttons.eq(0).click();
      expect(value).to.equal(2);
    });
  });

  describe("Close", function() {
    it("should close dialog on click of 'X' (close) button", function() {
      var $button = $(".ui-dialog-titlebar-close");

      // Make sure it's open
      dialog.$form.dialog("open");
      expect(dialog.$container).to.exist;
      expect(dialog.$container.length).to.equal(1);
      expect(dialog.$container.get(0).style.display).to.equal("");

      expect($button).to.exist;
      expect($button.length).to.equal(1);

      $button.click();
      expect(dialog.$container.get(0).style.display).to.equal("none");
    });

    it("should close the dialog on negative button press", function() {
      var $buttons = dialog.$container.find(".ui-dialog-buttonset button");

      // Make sure it's open
      dialog.$form.dialog("open");
      expect(dialog.$container).to.exist;
      expect(dialog.$container.length).to.equal(1);
      expect(dialog.$container.get(0).style.display).to.equal("");

      expect($buttons).to.exist;
      expect($buttons.length).to.equal(2);

      $buttons.eq(1).click();
      expect(dialog.$container.get(0).style.display).to.equal("none");
    });

    // WARNING!
    // THIS NEEDS TO SIT HERE TO RUN AFTER EVERYTHING ABOVE IT.
    // See comment opening the (below) "With Errors" testing.
    after(function() {
      $("#" + SUBMIT_BUTTON_ID).remove();
      $("#" + FORM_ID)
        .dialog("destroy")
        .remove();
    });
  });

  /*
   * WARNING!
   * We need to make sure we we have reset the document before continuging as we
   * need to now start simulating with and without errors. This would be more
   * difficult to do if the original dialog and/or form still existed, simply
   * because things get confusing (as did in initial attempt for these tests).
   **/

  describe("With Errors", function() {
    var WITH_ERRORS_FORM_ID = "form-test-with-error";
    var WITH_ERRORS_SUBMIT_ID = "submit-test-with-error";
    var dialogWithErrors;

    beforeEach(function() {
      var $form = $(`<form action="/" method="post">
                       <span class="govuk-error-message">This is an error</span>
                       <input type="text" value="some value here" name="some_input" />
                       <input type="submit" value="Submit button" />
                     </form>`);

      var $submit = $form.find("[type=submit]");

      $submit.attr("id", WITH_ERRORS_SUBMIT_ID);
      $form.attr("id", WITH_ERRORS_FORM_ID);
      $(document.body).append($form);
      dialogWithErrors = new ActivatedFormDialog($form, {
        cancelText: TEXT_CANCEL,
        okText: $submit.val(),
        $activator: $submit,
        selectorErrors: ".govuk-error-message",
        removeErrorClasses: "govuk-error-message"
      });
    });

    afterEach(function() {
      $("#" + WITH_ERRORS_SUBMIT_ID).remove();
      $("#" + WITH_ERRORS_FORM_ID)
        .dialog("destroy")
        .remove();
    });

    it("should make any found errors available public property", function() {
      expect(dialogWithErrors).to.exist;
      expect(dialogWithErrors.$errors).to.exist;
      expect(dialogWithErrors.$errors.length).to.equal(1);
      expect(dialogWithErrors.$errors.eq(0).text()).to.equal("This is an error");
    });

    it("should be open on page load when errors are present", function() {
      expect(dialogWithErrors.$errors.length).to.equal(1);

      expect(dialogWithErrors.$container).to.exist;
      expect(dialogWithErrors.$container.length).to.equal(1);
      expect(dialogWithErrors.$container.get(0).style.display).to.equal("");

      // And then double check against a closed state
      dialogWithErrors.$form.dialog("close");
      expect(dialogWithErrors.$container.get(0).style.display).to.equal("none");
    });

    it("should clear any stored errors with clearErrors() method", function() {
      expect(dialogWithErrors.$errors).to.exist;
      expect(dialogWithErrors.$errors.length).to.equal(1);

      dialogWithErrors.clearErrors();
      expect(dialogWithErrors.$errors.length).to.equal(0);
    });

    it("should clear any stored errors when negative (cancel) button is clicked", function() {
      dialogWithErrors.open();

      expect(dialogWithErrors.$errors).to.exist;
      expect(dialogWithErrors.$errors.length).to.equal(1);

      dialogWithErrors.close();
      expect(dialogWithErrors.$errors.length).to.equal(0);
    });

    it("should clear any stored errors when negative (cancel) button is clicked", function() {
      var $buttons = dialogWithErrors.$container.find(".ui-dialog-buttonset button");

      expect($buttons.length).to.equal(2);
      dialogWithErrors.open();

      expect(dialogWithErrors.$errors).to.exist;
      expect(dialogWithErrors.$errors.length).to.equal(1);

      $buttons.eq(1).click();
      expect(dialogWithErrors.$errors.length).to.equal(0);
    });
  });

  describe("Without Errors", function() {
    var WITHOUT_ERRORS_FORM_ID = "form-test-without-error";
    var WITHOUT_ERRORS_SUBMIT_ID = "submit-test-without-error";
    var dialogWithoutErrors;

    beforeEach(function() {
      var $form = $(`<form action="/" method="post">
                       <input type="text" value="some value here" name="some_input" />
                       <input type="submit" value="Submit button" />
                     </form>`);

      var $submit = $form.find("[type=submit]");

      $submit.attr("id", WITHOUT_ERRORS_SUBMIT_ID);
      $form.attr("id", WITHOUT_ERRORS_FORM_ID);
      $(document.body).append($form);
      dialogWithoutErrors = new ActivatedFormDialog($form, {
        cancelText: TEXT_CANCEL,
        okText: $submit.val(),
        activator: $submit
      });
    });

    afterEach(function() {
      $("#" + WITHOUT_ERRORS_SUBMIT_ID).remove();
      $("#" + WITHOUT_ERRORS_FORM_ID)
        .dialog("destroy")
        .remove();
    });

    it("should be closed on page load when no errors are present", function() {
      expect(dialogWithoutErrors.$errors).to.exist;
      expect(dialogWithoutErrors.$errors.length).to.equal(0);

      expect(dialogWithoutErrors.$container).to.exist;
      expect(dialogWithoutErrors.$container.length).to.equal(1);
      expect(dialogWithoutErrors.$container.get(0).style.display).to.equal("none");

      // Now open it to prove test was correct.
      dialogWithoutErrors.open();
      expect(dialogWithoutErrors.$container.get(0).style.display).to.equal("");
    });
  });
});
