require("../../setup");

describe("DownForwardUpPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "downforwarduppath-for-testing-properties-container";
  const COMPONENT_ID = "downforwarduppath-for-testing-properties-connector";

  describe("Properties", function() {
    var created;
    const POINTS = {
                     from_x: 701,
                     from_y: 125,
                     to_x: 1250,
                     to_y: 63,
                     via_x: 525,
                     via_y: 563
                   }

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('DownForwardUpPath', COMPONENT_ID, POINTS, {
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
      expect(created.connector.path).to.equal("M 701,125 v428 a10,10 0 0 0 10,10 h505 a10,10 0 0 0 10,-10 v-480 a10,10 0 0 1 10,-10 h14");
    });

    it('should calculate the correct dimensions', function() {
        var dimensions = created.connector.dimensions.current;
        expect(dimensions.down).to.equal(428);
        expect(dimensions.forward1).to.equal(505);
        expect(dimensions.up).to.equal(480);
    });


    it("should return points set in constructor", function() {
      expect(created.connector.points).to.exist;
      expect(created.connector.points.from_x).to.equal(POINTS.from_x);
      expect(created.connector.points.from_y).to.equal(POINTS.from_y);
    });

    it("should make DownForwardUpPath.type public", function() {
      expect(created.connector.type).to.exist;
      expect(created.connector.type).to.equal("DownForwardUpPath");
    });

    it("should make $node public", function() {
      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);
    });
  });
});
