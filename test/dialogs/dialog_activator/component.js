require('../../setup');

describe("DialogActivator", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView();
      created = helpers.createActivator(c.ID_LINK)
    });

    after(function() {
      helpers.teardownView();
      created.$node.remove();
      created = {};
    });

 
   it("should have the basic HTML in place", function() {
      var $activator = $("#" + c.ID_LINK);

      expect($activator.length).to.equal(1);
      expect($activator.get(0).nodeName.toLowerCase()).to.equal("a");
      expect($activator.text()).to.equal(created.$node.text());
      expect($activator.get(0)).to.equal(created.$node.get(0));
    });

    it("should apply CSS classnames passed as param");
    it("should use text passed as param");
    it("should expose the dialog as public");
    it("should expose the $node as public");
    it("should expose instance as data attribute on the $node");
    it("should add created node to DOM");
    it("should place created node after/before (??) dialog");
    it("should open the dialog on button click");

  });

});
