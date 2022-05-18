require('./setup');

describe("DialogConfiguration", function() {

  const DialogConfiguration = require('../app/javascript/src/component_dialog_configuration');
  const TEXT_CANCEL = "Dialog says Cancel";
  const TEXT_OK = "Dialog says Ok";
  const COMPONENT_CLASS = "DialogConfiguration";
  const DIALOG_CLASSES = "dialog-classname and-something";
  const DIALOG_ID = "component-dialog-configuration-test-id";
  const CONTAINER_ID = "component-dialog-configuration-test-container";
  var dialog;

  before(function() {
    // jQuyery is present in document because the
    // components use it, so we can use it here.

    var $container = $("<div></div>");
    var $node = $(`<div class="component component-dialog component-dialog-configuration">
          <div data-node="content"></div>
        </div>`);

    $node.attr("id", DIALOG_ID);
    $container.attr("id", CONTAINER_ID);
    $container.append($node);
    $(document.body).append($container);

    dialog = new DialogConfiguration($node, {
      autoOpen: false,
      cancelText: TEXT_CANCEL,
      okText: TEXT_OK,
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

    it("should have the component class name present", function() {
      expect($("#" + DIALOG_ID).parents("." + COMPONENT_CLASS).length).to.equal(1);
    });
  });

  describe("Config", function() {
    it("should apply CSS classnames passed in config", function() {
       var $parent = $("#" + DIALOG_ID).parents("." + COMPONENT_CLASS);
       expect($parent.get(0).className).to.include(DIALOG_CLASSES);
    });

    it("should use config.okText as button text", function() {
       var $button = $("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($button.length).to.equal(2);
       expect($button.eq(0).text()).to.equal(TEXT_OK);
    });

    it("should use config.cancelText as button text", function() {
       var $button = $("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($button.length).to.equal(2);
       expect($button.eq(1).text()).to.equal(TEXT_CANCEL);
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
      expect(dialog._elements.content).to.exist;
      expect(dialog._elements.content.length).to.equal(1);
    });

    it("should make (public but indicated as) private reference to config", function() {
      expect(dialog._config).to.exist;
      expect(dialog._config.cancelText).to.equal(TEXT_CANCEL);
      expect(dialog._config.okText).to.equal(TEXT_OK);
    });
  });

  describe("Open", function() {
    it("should open the dialog with public open() method", function() {
      var $parent = dialog.$node.parents("." + COMPONENT_CLASS);
      expect($parent).to.exist;
      expect($parent.length).to.equal(1);
      expect($parent.get(0).style.display).to.equal("none");

      dialog.open("");
      expect($parent.get(0).style.display).to.equal("");
    });

    it("should set the action passed as _saveAction", function() {
      var original  = function() { 1 + 1 }
      var something = function() { 2 + 2 }

      // Setting directly but this is not how we'd expect to use it.
      dialog._saveAction = original;

      // Prove this check works
      expect(dialog._saveAction).to.equal(original);

      // Now use the open() method to set new function properly
      dialog.open({}, something);

      // Use the check above but with new expected value
      expect(dialog._saveAction).to.equal(something);
    });
  });

  describe("Content", function() {
    it("should set element text with content method", function() {
      var $content = dialog.$node.find("[data-node='content']");

      expect($content).to.exist;
      expect($content.length).to.equal(1);
      expect($content.text()).to.equal("");

      dialog.content = { content: "<p>Updated content</p>" };
      expect($content.html()).to.equal("<p>Updated content</p>");
    });

    it("should return element with get content method", function() {
      var html = "<p>This is some content</p>";
      var content = { content: html }

      // First make sure it's empty and check it exists.
      dialog.content = { content: "" }
      expect(dialog.content).to.exist;
      expect(dialog.content.length).to.equal(1);
      expect(dialog.content.html()).to.equal("");

      // Then populate it and check again to make sure testing is correct.
      dialog.content = content;
      expect(dialog.content.html()).to.equal(html);
    });

    it("should load passed text into the dialog through the open() method", function() {
      var $content = $("[data-node='content']");

      // Make sure it's empty and $node exists.
      expect($content).to.exist;
      expect($content.length).to.equal(1);

      // Manually clear and populate it to check DOM is working right.
      $content.empty();
      $content.html("<p>General html here</p>");
      expect($content.html()).to.equal("<p>General html here</p>");

      // Use the dialog.open functionality to do what the manual process did.
      dialog.open({ content: "<p>Updated content</p>" })
      expect($content.html()).to.equal("<p>Updated content</p>");
    });
  });

  describe("Close", function() {
    it("should close dialog on click of 'X' (close) button", function() {
      var $dialog = $("." + COMPONENT_CLASS);
      var $button = $(".ui-dialog-titlebar-close");

      expect($dialog).to.exist;
      expect($dialog.length).to.equal(1);

      expect($button).to.exist;
      expect($button.length).to.equal(1);

      dialog.open({ content: "nothing much" });
      expect($dialog.get(0).style.display).to.equal("");

      $button.click();
      expect($dialog.get(0).style.display).to.equal("none");
    });

    it("should close the dialog on negative button press", function() {
      var $dialog = $("." + COMPONENT_CLASS);
      var $buttons = $("[role='dialog']").find(".ui-dialog-buttonset button");

      expect($buttons.length).to.equal(2);
      expect($buttons.eq(1).text()).to.equal(TEXT_CANCEL);

      dialog.open({ content: "testing button close" });
      expect($dialog.get(0).style.display).to.equal("");

      $buttons.eq(1).click();
      expect($dialog.get(0).style.display).to.equal("none");
    });

    it("should close the dialog on affirmative button press", function() {
      var $dialog = $("." + COMPONENT_CLASS);
      var $buttons = $("[role='dialog']").find(".ui-dialog-buttonset button");

      expect($buttons.length).to.equal(2);
      expect($buttons.eq(0).text()).to.equal(TEXT_OK);

      dialog.open({ content: "testing button close" });
      expect($dialog.get(0).style.display).to.equal("");

      $buttons.eq(0).click();
      expect($dialog.get(0).style.display).to.equal("none");
    });
  });

  describe("Save", function() {
    it("should run safely without passing action to open", function() {

      // Open without passing a function should set action to blank function
      dialog.open({})
      expect(typeof dialog._saveAction).to.equal("function");

      // Since it is the default blank function we can test the save() method.
      // If all is fine the expectation should run without a fail.
      dialog.save();
      expect(1).to.equal(1);
    });

    it("should run the set action passed to open", function() {
      var value = 1;

      // Open with passed a function and check exists
      dialog.open({}, function() { value++; });
      expect(dialog._saveAction).to.exist;

      dialog.save();

      // The function should still affect the value if it ran properly
      expect(value).to.equal(2);
    });
  });
});
