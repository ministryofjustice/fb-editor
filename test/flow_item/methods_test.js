require("../setup");

describe("FlowItem", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "flowitem-for-testing-methods-container";

  describe("Methods", function() {
    var created;

    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createFlowItem(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    // At time of writing FlowItem class has no methods.
    // This file is here for any future additions.
    it("should have no method, yet");

  });

});
