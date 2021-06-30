require('./setup');
const expect = require('chai').expect;

describe("Confirmation Dialog", function() {

  const DialogConfirmation = require('../app/javascript/src/component_dialog_confirmation');
  const CANCEL_TEXT = "Dialog says Cancel";
  const OK_TEXT = "Dialog says Ok";
  const ACTIVATOR_CLASSES = "activator-classname and-some-activator";
  const BUTTON_CLASSES = "button-classname and-some-button";
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
        "ui-activator": ACTIVATOR_CLASSES,
        "ui-button": BUTTON_CLASSES,
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
  });
});
