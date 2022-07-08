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

    /* TEST METHOD:  get path()
     **/
    it("should return the path", function() {
      expect(created.connector.path).to.exist;
      expect(created.connector.path).to.equal(""); // Base class does not set anything.
    });


    /* TEST METHOD: build()
     **/
    it("should build the $node", function() {
      expect(created.connector.build).to.exist;
      expect(created.connector.$node).to.not.exist;

      // Now call the build() function and see what happens.
      created.connector.build();

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
