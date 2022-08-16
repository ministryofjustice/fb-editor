require("../../setup");

describe("ForwardDownBackwardUpPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "forwardpath-for-testing-properties-container";
  const COMPONENT_ID = "forwardpath-for-testing-properties-connector";

  describe("Properties", function() {
    var created;
    const POINTS = {
      via_x: 80,
      via_y: 0,
      from_x: 1451,
      from_y: 313,
      to_x: 299,
      to_y: 63,
      xDifference: 1152,
      yDifference: 250
    }

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('ForwardDownBackwardUpPath', COMPONENT_ID, POINTS, {
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

    it("should make ForwardDownBackwardUpPath.id public", function() {
      expect(created.connector.id).to.exist;
      expect(created.connector.id).to.equal(COMPONENT_ID);
    });

    it("should make ForwardDownBackwardUpPath.points public", function() {
      expect(created.connector.points).to.exist;
      expect(created.connector.points.from_x).to.equal(POINTS.from_x);
      expect(created.connector.points.from_y).to.equal(POINTS.from_y);
    });

    it("should make ForwardDownBackwardUpPath.from public", function() {
      expect(created.connector.from).to.exist;
      expect(created.connector.from.id).to.exist;
      expect(created.connector.from.id).to.equal(c.FAKE_FLOW_ITEM_1.id);
    });

    it("should make ForwardDownBackwardUpPath.to public", function() {
      expect(created.connector.to).to.exist;
      expect(created.connector.to.id).to.exist;
      expect(created.connector.to.id).to.equal(c.FAKE_FLOW_ITEM_2.id);
    });

    it("should make ForwardDownBackwardUpPath.type public", function() {
      expect(created.connector.type).to.exist;
      expect(created.connector.type).to.equal("ForwardDownBackwardUpPath");
    });

    it("should make $node public", function() {
      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);
    });
  });
});
