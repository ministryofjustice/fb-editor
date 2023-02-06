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

    it("should return path set in constructor", function() {
      expect(created.connector.path).to.exist;
      expect(created.connector.path).to.equal("M 701,125 v178 a10,10 0 0 0 10,10 h505 a10,10 0 0 1 10,10 v331 a10,10 0 0 0 10,10 h304");
    });

    it('should calculate the correct dimensions', function() {
        var dimensions = created.connector.dimensions.current;
        expect(dimensions.down1).to.equal(178);
        expect(dimensions.forward1).to.equal(505);
        expect(dimensions.down2).to.equal(331);
        expect(dimensions.forward2).to.equal(304);
    });

    it("should return points set in constructor", function() {
      expect(created.connector.points).to.exist;
      expect(created.connector.points.from_x).to.equal(POINTS.from_x);
      expect(created.connector.points.from_y).to.equal(POINTS.from_y);
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
