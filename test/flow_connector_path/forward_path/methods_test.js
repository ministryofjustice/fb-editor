require("../../setup");

describe("ForwardPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "forwardpath-for-testing-methods-container";
  const COMPONENT_ID = "forwardpath-for-testing-methods-connector";

  describe("Methods", function() {
    var created;
    const POINTS = {
          from_x: 10,
          from_y: 12,
          to_x: 25,
          to_y: 27,
          via_x: 20
        };

    beforeEach(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('ForwardPath', COMPONENT_ID, POINTS, {
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

      expect(created.connector.$node.hasClass("ForwardPath")).to.be.true;
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
     * Because the ForwardPath class only produces one line.
     **/
    it("should return the FlowConnectorLines", function() {
      expect(created.connector.lines).to.exist;
      expect(created.connector.lines().constructor).to.equal(Array);
      expect(created.connector.lines().length).to.equal(1);
    });

    it("should return the FlowConnectorLines only of matching type", function() {
      expect(created.connector.lines("foo").length).to.equal(0);
      expect(created.connector.lines("vertical").length).to.equal(0);
      expect(created.connector.lines("horizontal").length).to.equal(1);
    });


    /* TEST METHOD: linesForOverlapComparison()
     * Because the ForwardPath only has one line we cannot test much of this function.
     * No lines can be considered as overlapping due to how we evaluate the and draw
     * the ForwardPath lines as point 'a' to 'b' only, with no movement allowed and,
     * therefore, with anything else being considered potential overlapping lines.
     **/
    it("should return the FlowConnectorLines if they overlap", function() {
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison().length).to.equal(0);
    });

    it("should return the FlowConnectorLines of a matching type if they overlap", function() {
      // should get same result as without supplying a type.
      expect(created.connector.linesForOverlapComparison).to.exist;
      expect(created.connector.linesForOverlapComparison().constructor).to.equal(Array);
      expect(created.connector.linesForOverlapComparison("foo").length).to.equal(0);
      expect(created.connector.linesForOverlapComparison("vertical").length).to.equal(0);
      expect(created.connector.linesForOverlapComparison("horizontal").length).to.equal(0);
    });


    /* TEST METHOD: nudge()
     * Because the ForwardPath class only has one line it does not override the base
     * class nudge() function, so we cannot/do not need to test this function.
     **/
    it("CANNOT TEST: should return false (uses same as base class)");


    /* TEST METHOD: makeLinesVisibleForTesting()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("should make lines visible for testing purpose", function() {
      // First check things are as expected
      expect(created.connector.lines().length).to.equal(1);
      expect(created.connector.$node.siblings("svg").length).to.equal(0);

      // Now call the function
      created.connector.makeLinesVisibleForTesting();

      // Now check things have changed as expected
      expect(created.connector.lines().length).to.equal(1);
      expect(created.connector.$node.siblings("svg").length).to.equal(1);
      expect(created.connector.$node.siblings("svg").find("[style='stroke:red;']").length).to.equal(1);
    });


    /* TEST METHOD: avoidOverlap()
     * Because the ForwardPath only has one line that should not move, we cannot test this function.
     **/
    it("CANNOT TEST: should return true if overlap was fixed (found)");
    it("CANNOT TEST: should return false if overlap was not fixed (none found)");
  });
});
