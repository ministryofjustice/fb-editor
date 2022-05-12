require('../../setup');

describe("ActivatedFormDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const FORM_ID = "dialog-for-testing-methods";

  describe("Methods", function() {
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

    describe("Open", function() {
      it("should open the dialog with public open() method", function() {
        var $form = $("#" + FORM_ID);

        // Make sure it's closed
        $form.dialog("close");
        expect(created.dialog.$container).to.exist;
        expect(created.dialog.$container.length).to.equal(1);
        expect(created.dialog.$container.get(0).style.display).to.equal("none");

        created.dialog.open();
        expect(created.dialog.$container.get(0).style.display).to.equal("");
      });

      it("should open the dialog on activator button press", function() {
        var $form = $("#" + FORM_ID);

        // Make sure it's closed
        $form.dialog("close");
        expect(created.dialog.$container).to.exist;
        expect(created.dialog.$container.length).to.equal(1);
        expect(created.dialog.$container.get(0).style.display).to.equal("none");

        created.dialog.activator.$node.click();
        expect(created.dialog.$container.get(0).style.display).to.equal("");
      });
    });

    describe("Submit", function() {
      it("should submit the form when OK button is clicked", function() {
        var $form = $("#" + FORM_ID);
        var $buttons = created.dialog.$container.find(".ui-dialog-buttonset button");
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
        created.dialog.$form.dialog("open");
        expect(created.dialog.$container).to.exist;
        expect(created.dialog.$container.length).to.equal(1);
        expect(created.dialog.$container.get(0).style.display).to.equal("");

        expect($button).to.exist;
        expect($button.length).to.equal(1);

        $button.click();
        expect(created.dialog.$container.get(0).style.display).to.equal("none");
      });

      it("should close the dialog on negative button press", function() {
        var $buttons = created.dialog.$container.find(".ui-dialog-buttonset button");

        // Make sure it's open
        created.dialog.$form.dialog("open");
        expect(created.dialog.$container).to.exist;
        expect(created.dialog.$container.length).to.equal(1);
        expect(created.dialog.$container.get(0).style.display).to.equal("");

        expect($buttons).to.exist;
        expect($buttons.length).to.equal(2);

        $buttons.eq(1).click();
        expect(created.dialog.$container.get(0).style.display).to.equal("none");
      });
    });

  });
});
