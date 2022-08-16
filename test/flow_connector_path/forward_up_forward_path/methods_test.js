require("../../setup");

describe("ForwardUpForwardPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "forwardupforwardpath-for-testing-methods-container";
  const COMPONENT_ID = "forwardupforwardpath-for-testing-methods-connector";

  describe("Methods", function() {
    var created;
    var expectedPathValue = "M 1451,313 h70 a10,10 0 0 0 10,-10 v-230 a10,10 0 0 1 10,-10 h-2";
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
      created = helpers.createFlowConnectorPath('ForwardUpForwardPath', COMPONENT_ID, POINTS, {
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

    /* TEST METHOD:  path()
     *
     * Differs only from FlowConnectorPath tests by using specific dimensions.
     **/
    it("should return the path value set in constructor", function() {
      expect(created.connector.path()).to.exist;
      expect(created.connector.path()).to.equal(expectedPathValue);
    });

    it("should update (set) the path value when receiving new dimensions", function() {
      // Original value created by constructor.
      expect(created.connector.path()).to.equal(expectedPathValue);

      // Update with some new dimensions.
      created.connector.path({ forward1: 30, up: 250, forward2: 20 });
      expect(created.connector.path()).to.equal("M 1451,313 h30 a10,10 0 0 0 10,-10 v-250 a10,10 0 0 1 10,-10 h20");

      // Reset to avoid breaking any other tests.
      created.connector.path({ forward1: 70, up: 230, forward2: -2 });
      expect(created.connector.path()).to.equal(expectedPathValue);
    });


    /* TEST METHOD: build()
     *
     * Same method as FlowConnectorPath but with sub-class specific differences.
     **/
    it("should build the $node", function() {
      expect(created.connector.build).to.exist;
      expect(created.connector.$node).to.exist;

      // Now call the build() function and see what happens.
      created.connector.build();

      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);

      expect(created.connector.$node.hasClass("ForwardUpForwardPath")).to.be.true;
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
      expect(created.connector.$node.parent().get(0)).to.equal(created.connector._config.container.get(0));
    });

    /* TEST METHOD: lines()
     * The ForwardUpForwardPath class produces three lines;
     * two horizontal and one vertical.
     **/
    it("should return the FlowConnectorLines", function() {
      expect(created.connector.lines).to.exist;
      expect(created.connector.lines().constructor).to.equal(Array);
      expect(created.connector.lines().length).to.equal(3);
    });

    it("should return the FlowConnectorLines only of matching type", function() {
      expect(created.connector.lines("foo").length).to.equal(0);
      expect(created.connector.lines("vertical").length).to.equal(1);
      expect(created.connector.lines("horizontal").length).to.equal(2);
    });


    /* TEST METHOD: linesForOverlapComparison()
     * ForwardUpForwardPath shoule be able to move the vertical line for overlap
     * protection, but the horizontal lines would not be expected to move.
     **/
    it("should only return the FlowConnectorLines if they can overlap", function() {
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison().length).to.equal(1);
    });

    it("should return the FlowConnectorLines of a matching type if they can overlap", function() {
      // should get same result as without supplying a type.
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison("foo").length).to.equal(0);
      expect(created.connector.linesForOverlapComparison("vertical").length).to.equal(1);
      expect(created.connector.linesForOverlapComparison("horizontal").length).to.equal(0);
    });


    /* TEST METHOD: nudge()
     * Because the ForwardUpForwardPath class only has one line it does not override the base
     * class nudge() function, so we cannot/do not need to test this function.
     **/
    it("should return false when horizontal line specified", function() {
      expect(created.connector.nudge("forward1")).to.be.false;
      expect(created.connector.nudge("forward2")).to.be.false;
    });

    it("should return true when vertical line specified", function() {
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
      expect(created.connector.lines().length).to.equal(3);
      expect(created.connector.$node.siblings("svg").length).to.equal(0);

      // Now call the function
      created.connector.makeLinesVisibleForTesting();

      // Now check things have changed as expected
      expect(created.connector.lines().length).to.equal(3);
      expect(created.connector.$node.siblings("svg").length).to.equal(3);

      expect(created.connector.$node.siblings("svg").eq(0).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(1).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(2).find("[style='stroke:red;']").length).to.equal(1);
    });


    /* TEST METHOD: avoidOverlap()
     * ForwardUpForwardPath only has one vertical line that can move.
     **/
    it("should return true if overlap was fixed (found)", function() {
      var clashingPath = helpers.createFlowConnectorPath('ForwardUpForwardPath', COMPONENT_ID + "-overlap", POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });

      var originalPath = clashingPath.connector.path();
      expect(created.connector.avoidOverlap(clashingPath.connector)).to.be.true;
      expect(clashingPath.connector.path()).to.not.equal(originalPath);

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

      var originalPath = nonClashingPath.connector.path();
      expect(created.connector.avoidOverlap(nonClashingPath.connector)).to.be.false;
      expect(nonClashingPath.connector.path()).to.equal(originalPath);

      // clean up what we created on the fly.
      nonClashingPath.connector.$node.remove();
      nonClashingPath = {};
    });
  });
});
