require('../../setup');

describe("ActivatedDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.contstants;
  const COMPONENT_ID = "dialog-for-testing";

  var dialog;

  before(function() {
    var created = helpers.createDialog(COMPONENT_ID)
    $(document.body).append(created.$node);
    dialog = created.dialog;
  });

  after(function() {
  });

  describe("Component", function() {
    it("should have the basic HTML in place", function() {
      var $dialog = $("#" + COMPONENT_ID);
      expect($dialog.length).to.equal(1);
      expect($dialog.get(0).nodeName.toLowerCase()).to.equal("div");
    });

    it("should have the component class name present");
    it("should apply CSS classnames passed in config");
    it("should use config.okText as button text");
    it("should store an onOk handler when passed in the config");
    it("should use config.cancelText as button text");
    it("should store an onCancel handler when passed in the config");
    it("should make the instance available as data on the $node");
    it("should make the $node public");
    it("should make (public but indicated as) private reference to config");
    it("should make the activator public");
  });

});
