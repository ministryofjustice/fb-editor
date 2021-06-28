const expect = require('chai').expect;
const jsdom = require("jsdom");
const jquery = require('jquery');
const { JSDOM } = jsdom;
const Dialog = require('../app/javascript/src/component_dialog');

describe("Dialog", function() {
  const OK_TEXT = "Dialog says Ok";
  const DIALOG_CLASSES = "dialog-classname and-something";

  const dom = new JSDOM(`<html>
    <head>
      <title>Testing HTML document</title>
    </head>
    <body>
      <h1>Test HTML document</h1>
      <div id="main">
        <div class="component component-dialog" id="dialog">
          <h3 data-node="heading" class="heading">General heading here</h3>
          <p data-node="content">General message here</p>
        </div>
      </div>
    </body>
  </html>`);

  global.window = dom.window;
  global.document = window.document;
  global.jQuery = require( 'jquery' )( window );
  global.$ = jQuery;
  require('jquery-ui/ui/widget');
  require('jquery-ui/ui/unique-id');
  require('jquery-ui/ui/widgets/button');
  require('jquery-ui/ui/widgets/dialog');
  require('jquery-ui/ui/safe-active-element');
  require('jquery-ui/ui/data');
  require('jquery-ui/ui/tabbable');
  require('jquery-ui/ui/focusable');
  require('jquery-ui/ui/safe-blur');

  before(function() {
    // jQuyery is present in document because the
    // components use it, so we can use it here.
    var $node = $(document).find("#dialog");
    global.dialog = new Dialog($node, {
      autoOpen: false,
      okText: OK_TEXT,
      classes: {
        "ui-dialog": DIALOG_CLASSES
      }
    });
  });

  describe("HTML", function() {
    it("should have the basic HTML in place", function() {
      expect($("#dialog").length).to.equal(1);
    });

    it("should have the Dialog class name present", function() {
      expect($("#dialog").parents(".Dialog").length).to.equal(1);
    });

    it("should not have a default jQuery UI cancel button", function() {
       var $buttons = $("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($buttons.length).to.equal(1);
       expect($buttons.eq(0).text()).to.not.equal("Cancel");
    });
  });

  describe("Config", function() {
    it("should apply CSS classnames passed in config", function() {
       var $parent = $("#dialog").parents(".Dialog");
       expect($parent.get(0).className).to.include(DIALOG_CLASSES);
    });

    it("should use config.okText as button text", function() {
       var $button = $("[role='dialog']").find(".ui-dialog-buttonset button");
       expect($button.text()).to.include(OK_TEXT);
    });
  });

  describe("Properties", function() {
    it("should make the $node public", function() {
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.attr("id")).to.equal("dialog");
    });

    it("should make the instance available as data on the $node", function() {
      expect(dialog.$node).to.exist;
      expect(dialog.$node.length).to.equal(1);
      expect(dialog.$node.data("instance")).to.eql(dialog);
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

    it("It should set element text with content method", function() {
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
      var $dialog = $(".Dialog");
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
