require("../../setup");

describe("ForwardDownForwardPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "forwarddownforwardpath-for-testing-properties-container";
  const COMPONENT_ID = "forwarddownforwardpath-for-testing-properties-connector";

  describe("Properties", function() {
    var created;
    const POINTS = {
                     via_x: 80,
                     via_y: 0,
                     from_x: 2701,
                     from_y: 63,
                     to_x: 299,
                     to_y: 63,
                     xDifference: 2402,
                     yDifference: 0
                   }

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('ForwardDownForwardPath', COMPONENT_ID, POINTS, {
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
      expect(created.connector.path).to.equal("M 2701,63 h70 a10,10 0 0 1 10,10 v-20 a10,10 0 0 0 10,10 h2462");
    });

    it('should calculate the correct dimensions', function() {
        var dimensions = created.connector.dimensions.current;
        expect(dimensions.forward1).to.equal(70);
        expect(dimensions.down).to.equal(-20);
        expect(dimensions.forward2).to.equal(2462);
    });

    it("should return points set in constructor", function() {
      expect(created.connector.points).to.exist;
      expect(created.connector.points.from_x).to.equal(POINTS.from_x);
      expect(created.connector.points.from_y).to.equal(POINTS.from_y);
    });

    it("should make ForwardDownForwardPath.type public", function() {
      expect(created.connector.type).to.exist;
      expect(created.connector.type).to.equal("ForwardDownForwardPath");
    });

    it("should make $node public", function() {
      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);
    });
  });
});
