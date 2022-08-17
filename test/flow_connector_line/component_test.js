require("../setup");

describe("FlowConnectorLine", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconnectorline-for-testing-component-container";

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorLine(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    /* FlowConnectorLines do not produce an actual element to allow testing of the
     * HTML component make up but, the testOnlySvg() method should create an
     * element to see within the DOM and test against. Such tests will be done
     * within the methods_test.js file.
     */

    it("should have the basic HTML in place");
    it("should have the component class name present");

  });

});
