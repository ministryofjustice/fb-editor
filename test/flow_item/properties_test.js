require("../setup");

describe("FlowItem", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "flowitem-for-testing-properties-container";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createFlowItem(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    it("should return the $node", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.item.$node.get(0)).to.equal(created.$node.get(0));
    });

    it("should return the id", function() {
      expect(created.item.id).to.equal(COMPONENT_ID);
    });

    it("should return the next id value", function() {
      expect(created.item.next).to.equal(c.FAKE_FLOW_ITEM_CONFIG.next);
    });

    it("should return the row number", function() {
      expect(created.item.row).to.equal(c.FAKE_FLOW_ITEM_CONFIG.row);
    });

    it("should return the column number", function() {
      expect(created.item.column).to.equal(c.FAKE_FLOW_ITEM_CONFIG.column);
    });

    it("should return the coords", function() {
      expect(created.item.coords.x_in).to.equal(c.FAKE_FLOW_ITEM_CONFIG.x_in);
      expect(created.item.coords.x_out).to.equal(c.FAKE_FLOW_ITEM_CONFIG.x_out);
      expect(created.item.coords.x_y).to.equal(c.FAKE_FLOW_ITEM_CONFIG.x_y);
      expect(created.item.coords).to.eql({
                                           x_in: c.FAKE_FLOW_ITEM_CONFIG.x_in,
                                           x_out: c.FAKE_FLOW_ITEM_CONFIG.x_out,
                                           y: c.FAKE_FLOW_ITEM_CONFIG.y
                                         });
    });

  });

});
