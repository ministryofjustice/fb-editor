require("../setup");

describe("FlowConnectorPath", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconnectorpath-for-testing-methods-container";
  const COMPONENT_ID = "flowconnectorpath-for-testing-methods-connector";

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
      created = helpers.createFlowConnectorPath('FlowConnectorPath', COMPONENT_ID, POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });

      // Base class FlowConnectorPath does not call
      // buid() function from constructor but we only
      // want it when ready to test some funcitons,
      // so it's called directly inside tests.
      // created.connector.build();
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
     **/
    it("should render the $node", function() {
      expect(created.connector.$node).to.exist;
      expect(created.connector.$node.length).to.equal(1);
    });


    /* TEST METHOD: lines()
     * Because the base class does not have any lines we're limited on what can be tested.
     **/
    it("should return the FlowConnectorLines", function() {
      expect(created.connector.lines).to.exist;
      expect(created.connector.lines().constructor).to.equal(Array);
    });

    it("CANNOT TEST: should return the FlowConnectorLines only of matching type");


    /* TEST METHOD: linesForOverlapComparison()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("CANNOT TEST: should return the FlowConnectorLines if the overlap");
    it("CANNOT TEST: should return the FlowConnectorLines of a matching type if the overlap");


    /* TEST METHOD: nudge()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("CANNOT TEST: should return false (nothing is done by base class)");


    /* TEST METHOD: makeLinesVisibleForTesting()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("CANNOT TEST: should make lines visible for testing purpose");


    /* TEST METHOD: avoidOverlap()
     * Because the base class does not have any lines we cannot test this function.
     **/
    it("CANNOT TEST: should return true if overlap was fixed (found)");
    it("CANNOT TEST: should return false if overlap was not fixed (none found)");
  });
});
