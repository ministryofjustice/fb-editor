require("../setup");

describe("FlowConnectorPath", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconnectorpath-for-testing-properties-container";
  const COMPONENT_ID = "flowconnectorpath-for-testing-properties-connector";

  describe("Properties", function() {
    var created;
    const POINTS = {
          from_x: 10,
          from_y: 12,
          to_x: 25,
          to_y: 27,
          via_x: 20
        };

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('FlowConnectorPath', COMPONENT_ID, POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });

      // Base class FlowConnectorPath does not call build() function from constructor.
      created.connector.build();
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    it("should return path set in constructor", function() {
      expect(created.connector.path).to.exist;
      expect(created.connector.path).to.equal(""); // Base class does not set anything.
    });

    it("should return points set in constructor", function() {
      expect(created.connector.points).to.exist;
      expect(created.connector.points.from_x).to.equal(POINTS.from_x);
      expect(created.connector.points.from_y).to.equal(POINTS.from_y);
    });

  });
});
