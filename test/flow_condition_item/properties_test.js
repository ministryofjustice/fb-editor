require("../setup");

describe("FlowConditionItem", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconditionitem-for-testing-properties-container";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConditionItem(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    it("should return the $node", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.item.$node.get(0)).to.equal(created.$node.get(0));
    });

    it("should return the $from element", function() {
      expect(created.item.$from).to.exist;
      expect(created.item.$from.length).to.equal(1);
      expect(created.item.$from.get(0)).to.equal(created.config.$from.get(0));
    });

    it("should return the $next element", function() {
      expect(created.item.$next).to.exist;
      expect(created.item.$next.length).to.equal(1);
      expect(created.item.$next.get(0)).to.equal(created.config.$next.get(0));
    });

    it("should return the row number", function() {
      expect(created.item).to.exist;
      expect(created.item.row).to.equal(c.FLOW_CONDITION_ITEM_CONFIG.row);
    });

    it("should return the column number", function() {
      expect(created.item).to.exist;
      expect(created.item.column).to.equal(c.FLOW_CONDITION_ITEM_CONFIG.column);
    });

  });

});
