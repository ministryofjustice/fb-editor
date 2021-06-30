require('./setup');
const expect = require('chai').expect;

describe("Confirmation Dialog", function() {

  const DialogConfirmation = require('../app/javascript/src/component_dialog_confirmation');
  const CANCEL_TEXT = "Dialog says Cancel";
  const OK_TEXT = "Dialog says Ok";
  const DIALOG_CLASSES = "dialog-classname and-some-dialog";
  const DIALOG_ID = "component-dialog-confirmation-test-id";
  const CONTAINER_ID = "component-dialog-confirmation-test-container";
  var dialog;

  before(function() {
    // jQuyery is present in document because the
    // components use it, so we can use it here.

    var $container = $("<div></div>");
    var $dialog = $(`<div class="component component-dialog-confirmation">
          <h3 data-node="heading" class="heading">General heading here</h3>
          <p data-node="content">General message here</p>
        </div>`);

    $dialog.attr("id", DIALOG_ID);
    $container.attr("id", CONTAINER_ID);
    $container.append($dialog);
    $(document.body).append($container);

    dialog = new DialogConfirmation($dialog, {
      autoOpen: false,
      cancelText: CANCEL_TEXT,
      okText: OK_TEXT,
      classes: {
        "ui-dialog": DIALOG_CLASSES
      }
    });
  });

  after(function() {
    $("#" + DIALOG_ID).dialog("destroy");
    $("#" + CONTAINER_ID).remove();
  });

  describe("HTML", function() {
    it("should have the basic HTML in place", function() {
      expect($("#" + DIALOG_ID).length).to.equal(1);
    });

    it("should NOT have the Dialog class name present", function() {
      expect($("#" + DIALOG_ID).parents(".Dialog").length).to.equal(0);
    });

    it("should have the DialogConfirmation class name present", function() {
      expect($("#" + DIALOG_ID).parents(".DialogConfirmation").length).to.equal(1);
    });

    it("should have action two buttons", function() {
      var $parent = $("#" + DIALOG_ID).parents(".DialogConfirmation");
      var $buttons = $parent.find(".ui-dialog-buttonset button");
      expect($buttons.length).to.equal(2);
    });
  });

  describe("Config", function() {
    it("should apply CSS classnames passed in config", function() {
       var $parent = $("#" + DIALOG_ID).parents(".DialogConfirmation");
       expect($parent.get(0).className).to.include(DIALOG_CLASSES);
    });

    it("should use config.okText as OK button text", function() {
       var $button = $("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($button.eq(0).text()).to.include(OK_TEXT);
    });

    it("should use config.cancelText as Cancel button text", function() {
       var $button = $("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($button.eq(1).text()).to.include(CANCEL_TEXT);
    });
  });


  describe("Properties", function() {
    it("should make the $node public", function() {
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
    });

    it("should make the instance available as data on the $node", function() {
      var $node = $("#" + DIALOG_ID);
      expect($node).to.exist;
      expect($node.length).to.equal(1);
      expect($node.data("instance")).to.equal(dialog);
    });

    it("should make (public but indicated as) private reference to elements", function() {
      expect(dialog._elements).to.exist;

      expect(dialog._elements.heading).to.exist;
      expect(dialog._elements.heading.length).to.equal(1);

      expect(dialog._elements.content).to.exist;
      expect(dialog._elements.content.length).to.equal(1);

      expect(dialog._elements.ok).to.exist;
      expect(dialog._elements.ok.length).to.equal(1);

      expect(dialog._elements.cancel).to.exist;
      expect(dialog._elements.cancel.length).to.equal(1);
    });

    it("should make (public but indicated as) private reference to config", function() {
      expect(dialog._config).to.exist;
      expect(dialog._config.okText).to.equal(OK_TEXT);
    });

    it("should make (public but indicated as) private reference to action", function() {
      expect(dialog._action).to.exist;
      expect(typeof dialog._action).to.equal("function");
    });
  });

  describe("Content", function() {
    it("should return default text with content method", function() {
      var text = dialog.content;

      expect(text.heading).to.equal("General heading here");
      expect(text.content).to.equal("General message here");
      expect(text.ok).to.equal("Dialog says Ok");
    });

    it("should set element text with content method", function() {
      var $heading = $("[data-node='heading']");
      var $content = $("[data-node='content']");

      expect($heading).to.exist;
      expect($heading.length).to.equal(1);
      expect($heading.text()).to.equal("General heading here");

      expect($content).to.exist;
      expect($content.length).to.equal(1);
      expect($content.text()).to.equal("General message here");

      dialog.content = { heading: "Updated heading", content: "Updated content" }
      expect($heading.text()).to.equal("Updated heading");
      expect($content.text()).to.equal("Updated content");
    });

    it("should load passed text into the dialog through the open() method", function() {
      var $heading = $("[data-node='heading']");
      var $content = $("[data-node='content']");
      var $parent = $("#" + DIALOG_ID).parents(".DialogConfirmation");
      var $buttons = $parent.find(".ui-dialog-buttonset button");
      var $ok = $buttons.eq(0);
      var $cancel = $buttons.eq(1);

      expect($heading).to.exist;
      expect($heading.length).to.equal(1);

      expect($content).to.exist;
      expect($content.length).to.equal(1);

      expect($ok).to.exist;
      expect($ok.length).to.equal(1);

      expect($cancel).to.exist;
      expect($cancel.length).to.equal(1);

      $heading.text("General heading here");
      expect($heading.text()).to.equal("General heading here");

      $content.text("General message here");
      expect($content.text()).to.equal("General message here");

      $ok.text("Ok text");
      expect($ok.text()).to.equal("Ok text");

      $cancel.text("Cancel text");
      expect($cancel.text()).to.equal("Cancel text");

      dialog.open({ heading: "Updated heading", content: "Updated content", ok: "Updated ok", cancel: "Updated cancel" })
      expect($heading.text()).to.equal("Updated heading");
      expect($content.text()).to.equal("Updated content");
      expect($ok.text()).to.equal("Updated ok");
      expect($cancel.text()).to.equal("Updated cancel");
    });

    it("should update passed action for dialog through the open() method", function() {
      var originalAction = dialog._action;
      var newAction = function() { return 1 + 1; };

      expect(dialog._action).to.exist;
      expect(typeof dialog._action).to.equal("function");

      dialog.open({ heading: "Updated heading", content: "Updated content" }, newAction)
      expect(dialog._action).to.exist;
      expect(typeof dialog._action).to.equal("function");
      expect(dialog._action).to.not.equal(originalAction);
    });
  });

  describe("Actions", function() {
    it("should run dialog._action on OK button click", function() {
      var $parent = $("#" + DIALOG_ID).parents(".DialogConfirmation");
      var $buttons = $parent.find(".ui-dialog-buttonset button");
      var $element = $("<p>Original text</p>");

      $(document.body).append($element);
      expect($element.text()).to.equal("Original text");

      // Open and click OK
      dialog.open({}, function() { $element.text("Updated text"); });
      $buttons.eq(0).click();

      expect($element.text()).to.equal("Updated text");

      // Clean up.
      $element.remove();
    });

    it("should NOT run dialog._action on Cancel click", function() {
      var $parent = dialog.$node.parents(".DialogConfirmation");
      var $element = $("<p>Original text</p>");
      var $buttons = $parent.find(".ui-dialog-buttonset button");

      $(document.body).append($element);
      expect($element.text()).to.equal("Original text");

      // Dialog is closed...
      expect($parent).to.exist;
      expect($parent.length).to.equal(1);
      expect($parent.get(0).style.display).to.equal("none");

      // ...so we open it.
      dialog.open({}, function() { $element.text("Updated text"); });
      expect($parent.get(0).style.display).to.equal("");

      // Click the cancel button...
      $buttons.eq(1).click();

      // ...and check the action didn't change the text.
      expect($element.text()).to.equal("Original text");
      $element.remove();
    });
  });

  describe("Buttons", function() {
    it("should close the dialog on OK button click", function() {
      var $parent = dialog.$node.parents(".DialogConfirmation");
      var $buttons = $parent.find(".ui-dialog-buttonset button");

      // Dialog is closed...
      expect($parent).to.exist;
      expect($parent.length).to.equal(1);
      expect($parent.get(0).style.display).to.equal("none");

      // ...so we open it.
      dialog.open();
      expect($parent.get(0).style.display).to.equal("");

      // Click the OK button
      $buttons.eq(0).click();

      // Check the dialog is now closed
      expect($parent.get(0).style.display).to.equal("none");
    });

    it("should close the dialog on Cancel button click", function() {
      var $parent = dialog.$node.parents(".DialogConfirmation");
      var $buttons = $parent.find(".ui-dialog-buttonset button");

      // Dialog is closed...
      expect($parent).to.exist;
      expect($parent.length).to.equal(1);
      expect($parent.get(0).style.display).to.equal("none");

      // ...so we open it.
      dialog.open();
      expect($parent.get(0).style.display).to.equal("");

      // Click the Cancel button
      $buttons.eq(1).click();

      // Check the dialog is now closed
      expect($parent.get(0).style.display).to.equal("none");
    });

    it("should close the dialog on 'X' (Dialog closer) button click", function() {
      var $dialog = $(".DialogConfirmation");
      var $button = $(".ui-dialog-titlebar-close");

      expect($dialog).to.exist;
      expect($dialog.length).to.equal(1);

      expect($button).to.exist;
      expect($button.length).to.equal(1);

      dialog.open();
      expect($dialog.get(0).style.display).to.equal("");

      $button.click();
      expect($dialog.get(0).style.display).to.equal("none");
    });
  });
});
