require("../setup");

describe("FlowConditionItem", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconditionitem-for-testing-component-container";

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConditionItem(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    it("should have the basic HTML in place", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).tagName.toLowerCase()).to.equal("li");
      expect(created.$node.get(0).hasAttribute("data-from")).to.be.true;
      expect(created.$node.get(0).hasAttribute("data-next")).to.be.true;
    });

    it("should have the component class name present", function() {
      expect(created.$node.length).to.equal(1);
      expect(created.$node.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

  });

});
