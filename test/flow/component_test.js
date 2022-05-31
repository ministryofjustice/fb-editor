require("../setup");

describe("FlowConnectorPath", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "flowconnectorpath-for-testing-component";

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createFlowConnectorPath(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    it("should have the basic HTML in place", function() {
      var $container = $("#" + COMPONENT_ID);
      var $flowItem_1 = $("#" + c.FLOW_ITEM_1_ID, $container);
      var $flowItem_2 = $("#" + c.FLOW_ITEM_2_ID, $container);
      var $flowItems = $container.find(".flow-item");

      // Container is in place
      expect($container.length).to.equal(1);
      expect($container.get(0).nodeName.toLowerCase()).to.equal("div");

      // Flow item 1 is in place
      expect($flowItem_1.length).to.equal(1);
      expect($flowItems.first().get(0)).to.equal($flowItem_1.get(0));

      // Flow item 2 is in place
      expect($flowItem_2.length).to.equal(1);
      expect($flowItems.last().get(0)).to.equal($flowItem_2.get(0));
    });
  });
});
