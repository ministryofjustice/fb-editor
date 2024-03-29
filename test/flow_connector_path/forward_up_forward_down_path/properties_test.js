require("../../setup");

describe("ForwardUpForwardDownPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "forwardupforwarddownpath-for-testing-properties-container";
  const COMPONENT_ID = "forwardupforwarddownpath-for-testing-properties-connector";

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
      created = helpers.createFlowConnectorPath('ForwardUpForwardDownPath', COMPONENT_ID, POINTS, {
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

    it("should return path set in constructor", function() {
      expect(created.connector.path).to.exist;
      expect(created.connector.path).to.equal("M 10,12 h10 a10,10 0 0 0 10,-10 v-7 a10,10 0 0 1 10,-10 h-45 a10,10 0 0 1 10,10 v22 a10,10 0 0 0 10,10 h0");
    });

    it('should calculate the correct dimensions', function() {
        var dimensions = created.connector.dimensions.current;
        expect(dimensions.forward1).to.equal(10);
        expect(dimensions.up).to.equal(7);
        expect(dimensions.forward2).to.equal(-45);
        expect(dimensions.down).to.equal(22);
    });

    it("should return points set in constructor", function() {
      expect(created.connector.points).to.exist;
      expect(created.connector.points.from_x).to.equal(POINTS.from_x);
      expect(created.connector.points.from_y).to.equal(POINTS.from_y);
    });

    it("should make ForwardUpForwardDownPath.type public", function() {
      expect(created.connector.type).to.exist;
      expect(created.connector.type).to.equal("ForwardUpForwardDownPath");
    });

    it("should make $node public", function() {
      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);
    });
  });
});
