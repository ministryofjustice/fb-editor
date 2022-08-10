require("../../setup");

describe("DownForwardDownForwardPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "downforwarddownforwardpath-for-testing-properties-container";
  const COMPONENT_ID = "downforwarddownforwardpath-for-testing-properties-connector";

  describe("Properties", function() {
    var created;
    // Warning: made up coordinates because failed to create line in browser
    const POINTS = {
                     from_x: 701,
                     from_y: 125,
                     to_x: 1550,
                     to_y: 662.5,
                     via_x: 525,
                     via_y: 312.5
                   }

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('DownForwardDownForwardPath', COMPONENT_ID, POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    it("should make DownForwardDownForwardPath.id public", function() {
      expect(created.connector.id).to.exist;
      expect(created.connector.id).to.equal(COMPONENT_ID);
    });

    it("should make DownForwardDownForwardPath.points public", function() {
      expect(created.connector.points).to.exist;
      expect(created.connector.points.from_x).to.equal(POINTS.from_x);
      expect(created.connector.points.from_y).to.equal(POINTS.from_y);
    });

    it("should make DownForwardDownForwardPath.from public", function() {
      expect(created.connector.from).to.exist;
      expect(created.connector.from.id).to.exist;
      expect(created.connector.from.id).to.equal(c.FAKE_FLOW_ITEM_1.id);
    });

    it("should make DownForwardDownForwardPath.to public", function() {
      expect(created.connector.to).to.exist;
      expect(created.connector.to.id).to.exist;
      expect(created.connector.to.id).to.equal(c.FAKE_FLOW_ITEM_2.id);
    });

    it("should make DownForwardDownForwardPath.type public", function() {
      expect(created.connector.type).to.exist;
      expect(created.connector.type).to.equal("DownForwardDownForwardPath");
    });

    it("should make $node public", function() {
      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);
    });
  });
});
