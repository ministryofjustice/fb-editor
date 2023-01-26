require("../../setup");

describe("ForwardUpForwardDownPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "forwardupforwarddownpath-for-testing-methods-container";
  const COMPONENT_ID = "forwardupforwarddownpath-for-testing-methods-connector";

  describe("Methods", function() {
    var created;
    const POINTS = {
          from_x: 1451,
          from_y: 313,
          to_x: 1549,
          to_y: 63,
          via_x: 80,
          via_y: 0,
          xDifference: 98,
          yDifference: 250
        }

    beforeEach(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('ForwardUpForwardDownPath', COMPONENT_ID, POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });
    });

    afterEach(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });


    /* TEST METHOD: prop()
     **/
    it("should make prop(id) available", function() {
      expect(created.connector.prop("id")).to.exist;
      expect(created.connector.prop("id")).to.equal(COMPONENT_ID);
    });

    it("should make prop(from) available", function() {
      expect(created.connector.prop("from")).to.exist;
      expect(created.connector.prop("from").id).to.exist;
      expect(created.connector.prop("from").id).to.equal(c.FAKE_FLOW_ITEM_1.id);
    });

    it("should make prop(to) available", function() {
      expect(created.connector.prop("to")).to.exist;
      expect(created.connector.prop("to").id).to.exist;
      expect(created.connector.prop("to").id).to.equal(c.FAKE_FLOW_ITEM_2.id);
    });

    /* TEST METHOD: render()
     *
     * Same method as FlowConnectorPath but with sub-class specific differences.
     **/
    it("should render the $node", function() {
      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);

      expect(created.connector.$node.hasClass("ForwardUpForwardDownPath")).to.be.true;
    });

    it("should add the id to $node", function() {
      expect(created.connector.$node.attr("id")).to.equal(COMPONENT_ID);
    });

    it("should add the data-from attribute", function() {
      expect(created.connector.$node.attr("data-from")).to.equal(c.FAKE_FLOW_ITEM_1.id);
    });

    it("should add the data-to attribute", function() {
      expect(created.connector.$node.attr("data-to")).to.equal(c.FAKE_FLOW_ITEM_2.id);
    });

    it("should add the instance to $node", function() {
      expect(created.connector.$node.data("instance")).to.equal(created.connector);
    });

    it("should add the $node to $container", function() {
      expect(created.connector.$node.parent().get(0)).to.equal(created.config.container.get(0));
    });

    /* TEST METHOD: lines()
     * The ForwardUpForwardDownPath class produces three lines;
     * two horizontal and one vertical.
     **/
    it("should return the FlowConnectorLines", function() {
      expect(created.connector.lines).to.exist;
      expect(created.connector.lines().constructor).to.equal(Array);
      expect(created.connector.lines().length).to.equal(5);
    });

    it("should return the FlowConnectorLines only of matching type", function() {
      expect(created.connector.lines("foo").length).to.equal(0);
      expect(created.connector.lines("vertical").length).to.equal(2);
      expect(created.connector.lines("horizontal").length).to.equal(3);
    });


    /* TEST METHOD: linesForOverlapComparison()
     * ForwardUpForwardDownPath shoule be able to move the vertical line for overlap
     * protection, but the horizontal lines would not be expected to move.
     **/
    it("should only return the FlowConnectorLines if they can overlap", function() {
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison().length).to.equal(4);
    });

    it("should return the FlowConnectorLines of a matching type if they can overlap", function() {
      // should get same result as without supplying a type.
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison("foo").length).to.equal(0);
      expect(created.connector.linesForOverlapComparison("vertical").length).to.equal(2);
      expect(created.connector.linesForOverlapComparison("horizontal").length).to.equal(2);
    });


    /* TEST METHOD: nudge()
     * Because the ForwardUpForwardDownPath class only has one line it does not override the base
     * class nudge() function, so we cannot/do not need to test this function.
     **/
    it("should return false when 'forward1' or 'forward3' line specified", function() {
      expect(created.connector.nudge("forward1")).to.be.false;
      expect(created.connector.nudge("forward3")).to.be.false;
    });

    it("should return true when 'forward2' line specified", function() {
      expect(created.connector.nudge("forward2")).to.be.true;
    });

    it("should return true when 'up' or 'down' line specified", function() {
      expect(created.connector.nudge("up")).to.be.true;
      expect(created.connector.nudge("up")).to.be.true;
    });

    it("should return false when unmatched line specified", function() {
      expect(created.connector.nudge("foo")).to.be.false;
    });

    /* TEST METHOD: makeLinesVisibleForTesting()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("should make lines visible for testing purpose", function() {
      // First check things are as expected
      expect(created.connector.lines().length).to.equal(5);
      expect(created.connector.$node.siblings("svg").length).to.equal(0);

      // Now call the function
      created.connector.makeLinesVisibleForTesting();

      // Now check things have changed as expected
      expect(created.connector.lines().length).to.equal(5);
      expect(created.connector.$node.siblings("svg").length).to.equal(5);

      expect(created.connector.$node.siblings("svg").eq(0).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(1).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(2).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(3).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(4).find("[style='stroke:red;']").length).to.equal(1);
    });


    /* TEST METHOD: avoidOverlap()
     * ForwardUpForwardDownPath only has one vertical line that can move.
     **/
    it("should return true if overlap was fixed (found)", function() {
      var clashingPath = helpers.createFlowConnectorPath('ForwardUpForwardDownPath', COMPONENT_ID + "-overlap", POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });

      var originalPath = clashingPath.connector.path;
      expect(created.connector.avoidOverlap(clashingPath.connector)).to.be.true;
      expect(clashingPath.connector.path).to.not.equal(originalPath);

      // clean up what we created on the fly.
      clashingPath.connector.$node.remove();
      clashingPath = {};
    });

    it("should return false if overlap was not fixed (none found)", function() {
      const POINTS = {
          from_x: 10,
          from_y: 12,
          to_x: 25,
          to_y: 27,
          via_x: 20
        };

      var nonClashingPath = helpers.createFlowConnectorPath('ForwardPath', COMPONENT_ID + "-no-overlap",  POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });

      var originalPath = nonClashingPath.connector.path;
      expect(created.connector.avoidOverlap(nonClashingPath.connector)).to.be.false;
      expect(nonClashingPath.connector.path).to.equal(originalPath);

      // clean up what we created on the fly.
      nonClashingPath.connector.$node.remove();
      nonClashingPath = {};
    });
  });
});
