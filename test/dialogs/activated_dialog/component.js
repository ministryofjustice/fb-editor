require('../../setup');

describe("ActivatedDialog", function() {

  const helpers = require("./helpers.js");
  const c = helpers.contstants;

  before(function() {
  });

  after(function() {
  });

  describe("Component", function() {
    it("should have the basic HTML in place");
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
