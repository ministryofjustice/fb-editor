require("../../setup");

describe("DownForwardPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "downforwardpath-for-testing-methods-container";
  const COMPONENT_ID = "downforwardpath-for-testing-methods-connector";

  describe("Methods", function() {
    var created;
    var expectedPathValue = "M 701,125 v178 a10,10 0 0 0 10,10 h539";
    const POINTS = {
                     via_x: 0,
                     via_y: 0,
                     from_x: 701,
                     from_y: 125,
                     to_x: 1250,
                     to_y: 313,
                     xDifference: 549,
                     yDifference: 188
                   }

    beforeEach(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('DownForwardPath', COMPONENT_ID, POINTS, {
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
                      down: 278,
                      forward: 639
                    }

      // Original value created by constructor.
      expect(created.connector.path()).to.equal(expectedPathValue);
      expect(created.connector.config.dimensions.current).to.eql(original);

      // Update with some new dimensions.
      created.connector.path(updated);
      expect(created.connector.config.dimensions.current).to.eql(updated);
      expect(created.connector.path()).to.equal(String("M 701,125 v278 a10,10 0 0 0 10,10 h639"));

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

      expect(created.connector.$node.hasClass("DownForwardPath")).to.be.true;
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
     * The DownForwardPath class produces three lines;
     * two horizontal and one vertical.
     **/
    it("should return the FlowConnectorLines", function() {
      expect(created.connector.lines).to.exist;
      expect(created.connector.lines().constructor).to.equal(Array);
      expect(created.connector.lines().length).to.equal(2);
    });

    it("should return the FlowConnectorLines only of matching type", function() {
      expect(created.connector.lines("foo").length).to.equal(0);
      expect(created.connector.lines("vertical").length).to.equal(1);
      expect(created.connector.lines("horizontal").length).to.equal(1);
    });


    /* TEST METHOD: linesForOverlapComparison()
     * DownForwardPath shoule be able to move the vertical line for overlap
     * protection, but the horizontal lines would not be expected to move.
     **/
    it("should only return the FlowConnectorLines if they can overlap", function() {
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison().length).to.equal(0);
    });

    it("should return the FlowConnectorLines of a matching type if they can overlap", function() {
      // should get same result as without supplying a type.
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison("foo").length).to.equal(0);
      expect(created.connector.linesForOverlapComparison("vertical").length).to.equal(0);
      expect(created.connector.linesForOverlapComparison("horizontal").length).to.equal(0);
    });


    /* TEST METHOD: nudge()
     **/
    it("should return false when horizontal line specified", function() {
      expect(created.connector.nudge("down")).to.be.false;
    });

    it("should return false when vertical line specified", function() {
      expect(created.connector.nudge("down")).to.be.false;
    });

    it("should return false when unmatched line specified", function() {
      expect(created.connector.nudge("foo")).to.be.false;
      expect(created.connector.nudge("down1")).to.be.false;
    });

    /* TEST METHOD: makeLinesVisibleForTesting()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("should make lines visible for testing purpose", function() {
      // First check things are as expected
      expect(created.connector.lines().length).to.equal(2);
      expect(created.connector.$node.siblings("svg").length).to.equal(0);

      // Now call the function
      created.connector.makeLinesVisibleForTesting();

      // Now check things have changed as expected
      expect(created.connector.lines().length).to.equal(2);
      expect(created.connector.$node.siblings("svg").length).to.equal(2);

      expect(created.connector.$node.siblings("svg").eq(0).find("[style='stroke:red;']").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").eq(1).find("[style='stroke:red;']").length).to.equal(1);
    });


    /* TEST METHOD: avoidOverlap()
     * DownForwardPath does not have any overlapping lines so cannot test this (inherited) function.
     **/
    it("should return true if overlap was fixed (found)");
    it("should return false if overlap was not fixed (none found)");
  });
});
