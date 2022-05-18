require('./setup');

describe("Dialog", function() {

  const Dialog = require('../app/javascript/src/component_dialog');
  const OK_TEXT = "Dialog says Ok";
  const DIALOG_CLASSES = "dialog-classname and-something";
  const DIALOG_ID = "component-dialog-test-id";
  var dialog;

  before(function() {
    // jQuyery is present in document because the
    // components use it, so we can use it here.

    var $dialog = $(`<div class="component component-dialog">
          <h3 data-node="heading" class="heading">General heading here</h3>
          <p data-node="content">General message here</p>
        </div>`);

    $dialog.attr("id", DIALOG_ID);
    $(document.body).append($dialog);

    dialog = new Dialog($dialog, {
      autoOpen: false,
      okText: OK_TEXT,
      classes: {
        "ui-dialog": DIALOG_CLASSES
      }
    });
  });

  after(function() {
    $("#" + DIALOG_ID).dialog("destroy");
  });

  describe("HTML", function() {
    it("should have the basic HTML in place", function() {
      expect($("#" + DIALOG_ID).length).to.equal(1);
    });

    it("should have the Dialog class name present", function() {
      expect($("#" + DIALOG_ID).parents(".Dialog").length).to.equal(1);
    });

    it("should not have a default jQuery UI cancel button", function() {
       var $dialog = $("#" + DIALOG_ID);
       var $buttons = $dialog.parents("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($buttons.length).to.equal(1);
       expect($buttons.eq(0).text()).to.not.equal("Cancel");
    });
  });

  describe("Config", function() {
    it("should apply CSS classnames passed in config", function() {
       var $parent = $("#" + DIALOG_ID).parents(".Dialog");
       expect($parent.get(0).className).to.include(DIALOG_CLASSES);
    });

    it("should use config.okText as button text", function() {
       var $dialog = $("#" + DIALOG_ID);
       var $button = $dialog.parents("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($button.text()).to.include(OK_TEXT);
    });
  });

  describe("Properties", function() {
    it("should make the instance available as data on the $node", function() {
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.data("instance")).to.eql(dialog);
    });

    it("should make the $node public", function() {
      var dialog = $("#" + DIALOG_ID).data("instance");
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.attr("id")).to.equal(DIALOG_ID);
    });

    it("should make (public but indicated as) private reference to elements", function() {
      expect(dialog._elements).to.exist;
      expect(dialog._elements.heading).to.exist;
      expect(dialog._elements.content).to.exist;
      expect(dialog._elements.heading.length).to.equal(1);
      expect(dialog._elements.content.length).to.equal(1);
    });


    it("should make (public but indicated as) private reference to config", function() {
      expect(dialog._config).to.exist;
      expect(dialog._config.okText).to.equal(OK_TEXT);
    });
  });

  describe("Open", function() {
    it("should open the dialog with public open() method", function() {
      var $parent = dialog.$node.parents(".Dialog");
      expect($parent).to.exist;
      expect($parent.length).to.equal(1);
      expect($parent.get(0).style.display).to.equal("none");

      dialog.open();
      expect($parent.get(0).style.display).to.equal("");
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
      var $container = $("#" + DIALOG_ID + "-container");
      var $heading = $container.find("[data-node='heading']");
      var $content = $container.find("[data-node='content']");

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
      var $container = $("#" + DIALOG_ID + "-container");
      var $heading = $container.find("[data-node='heading']");
      var $content = $container.find("[data-node='content']");

      expect($heading).to.exist;
      expect($content).to.exist;
      expect($heading.length).to.equal(1);
      expect($content.length).to.equal(1);

      $heading.text("General heading here");
      $content.text("General message here");
      expect($heading.text()).to.equal("General heading here");
      expect($content.text()).to.equal("General message here");

      dialog.open({ heading: "Updated heading", content: "Updated content" })
      expect($heading.text()).to.equal("Updated heading");
      expect($content.text()).to.equal("Updated content");
    });
  });

  describe("Close", function() {
    it("should close dialog on click of 'X' (close) button", function() {
      var $container = $("#" + DIALOG_ID + "-container");
      var $button = $(".ui-dialog-titlebar-close");

      expect($container).to.exist;
      expect($container.length).to.equal(1);

      expect($button).to.exist;
      expect($button.length).to.equal(1);

      dialog.open();
      expect($container.get(0).style.display).to.equal("");

      $button.click();
      expect($container.get(0).style.display).to.equal("none");
    });
  });

});
