require("../setup");

describe("FlowItem", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "flowitem-for-testing-component-container";

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createFlowItem(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    it("should have the basic HTML in place", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).tagName.toLowerCase()).to.equal("div");
      expect(created.$node.find("h3").length).to.equal(1);
      expect(created.$node.find("p").length).to.equal(1);
    });

    it("should have the component class name present", function() {
      expect(created.$node.length).to.equal(1);
      expect(created.$node.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

  });

});
