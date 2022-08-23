require("../../setup");

describe("DownForwardDownForwardPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "downforwarddownforwardpath-for-testing-component-container";
  const COMPONENT_ID = "downforwarddownforwardpath-for-testing-component-connector";

  describe("Methods", function() {
    var created;
    var expectedPathValue = "M 701,125 v178 a10,10 0 0 0 10,10 h505 a10,10 0 0 1 10,10 v331 a10,10 0 0 0 10,10 h304";
    // Warning: made up coordinates because failed to create line in browser
    const POINTS = {
                     from_x: 701,
                     from_y: 125,
                     to_x: 1550,
                     to_y: 662.5,
                     via_x: 525,
                     via_y: 312.5
                   }

    beforeEach(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('DownForwardDownForwardPath', COMPONENT_ID, POINTS, {
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
      var original = created.connector.config.dimensions.original;
      var updated = {
                      down1: 278,
                      forward1: 605,
                      down2: 431,
                      forward2: 404
                    }

      // Original value created by constructor.
      expect(created.connector.path()).to.equal(expectedPathValue);
      expect(created.connector.config.dimensions.current).to.eql(original);

      // Update with some new dimensions.
      created.connector.path(updated);
      expect(original).to.not.eql(updated);
      expect(created.connector.config.dimensions.current).to.eql(updated);
      expect(created.connector.path()).to.equal(String("M 701,125 v278 a10,10 0 0 0 10,10 h605 a10,10 0 0 1 10,10 v431 a10,10 0 0 0 10,10 h404"));

      // Reset to avoid breaking any other tests.
      created.connector.path(original);
      expect(created.connector.config.dimensions.current).to.eql(original);
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

      expect(created.connector.$node.hasClass("DownForwardDownForwardPath")).to.be.true;
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
     * The DownForwardDownForwardPath class produces three lines;
     * two horizontal and one vertical.
     **/
    it("should return the FlowConnectorLines", function() {
      expect(created.connector.lines).to.exist;
      expect(created.connector.lines().constructor).to.equal(Array);
      expect(created.connector.lines().length).to.equal(4);
    });

    it("should return the FlowConnectorLines only of matching type", function() {
      expect(created.connector.lines("foo").length).to.equal(0);
      expect(created.connector.lines("vertical").length).to.equal(2);
      expect(created.connector.lines("horizontal").length).to.equal(2);
    });


    /* TEST METHOD: linesForOverlapComparison()
     * DownForwardDownForwardPath shoule be able to move the vertical line for overlap
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
     **/
    it("should return false when horizontal line specified", function() {
      expect(created.connector.nudge("forward1")).to.be.false;
    });

    it("should return true when vertical line specified", function() {
      expect(created.connector.nudge("down2")).to.be.true;
    });

    it("should return false when unmatched line specified", function() {
      expect(created.connector.nudge("foo")).to.be.false;
      expect(created.connector.nudge("down1")).to.be.false;
      expect(created.connector.nudge("forward1")).to.be.false;
      expect(created.connector.nudge("forward2")).to.be.false;
    });

    /* TEST METHOD: makeLinesVisibleForTesting()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("should make lines visible for testing purpose", function() {
      // First check things are as expected
      expect(created.connector.lines().length).to.equal(4);
      expect(created.connector.$node.siblings("svg").length).to.equal(0);

      // Now call the function
      created.connector.makeLinesVisibleForTesting();

      // Now check things have changed as expected
      expect(created.connector.lines().length).to.equal(4);
      expect(created.connector.$node.siblings("svg").length).to.equal(4);

      expect(created.connector.$node.siblings("svg").eq(0).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(1).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(2).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(3).find("[style='stroke:red;']").length).to.equal(1);
    });


    /* TEST METHOD: avoidOverlap()
     * DownForwardDownForwardPath only has one vertical line that can move.
     **/
    it("should return true if overlap was fixed (found)", function() {
      var clashingPath = helpers.createFlowConnectorPath('DownForwardDownForwardPath', COMPONENT_ID + "-overlap", POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });

      var originalPath = clashingPath.connector.path();
      expect(clashingPath.connector.config.dimensions).to.eql(created.connector.config.dimensions);
      expect(created.connector.avoidOverlap(clashingPath.connector)).to.be.true;
      expect(clashingPath.connector.path()).to.not.eql(originalPath);

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
