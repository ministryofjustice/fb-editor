require("../../setup");

describe("ForwardDownForwardPath", function() {
  const helpers = require("../helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "forwarddowndforwardpath-for-testing-component-container";
  const COMPONENT_ID = "forwarddowndforwardpath-for-testing-component-connector";

  describe("Component", function() {
    var created;
    const POINTS = {
      via_x: 80,
      via_y: 0,
      from_x: 1451,
      from_y: 313,
      to_x: 299,
      to_y: 63,
      xDifference: 1152,
      yDifference: 250
    }

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('ForwardDownForwardPath', COMPONENT_ID,  POINTS, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    it("should have the basic HTML in place", function() {
      var $container = $("#" + CONTAINER_ID);
      var $flowItem_1 = $("#" + c.FAKE_FLOW_ITEM_1.id, $container);
      var $flowItem_2 = $("#" + c.FAKE_FLOW_ITEM_2.id, $container);
      var $flowItems = $container.find(".flow-item");
      var $svg = $container.find("#" + COMPONENT_ID);

      // Container is in place
      expect($container.length).to.equal(1);
      expect($container.get(0).nodeName.toLowerCase()).to.equal("div");

      // Flow item 1 is in place
      expect($flowItem_1.length).to.equal(1);
      expect($flowItems.first().get(0)).to.equal($flowItem_1.get(0));

      // Flow item 2 is in place
      expect($flowItem_2.length).to.equal(1);
      expect($flowItems.last().get(0)).to.equal($flowItem_2.get(0));

      // FlowConnectorPath is in place
      expect($svg.length).to.equal(1);
      expect($svg.get(0).tagName.toLowerCase()).to.equal("svg");
      expect($container.has($svg.get(0)).length).to.equal(1);
    });

    it("should have the component class name present", function() {
      var $svg = $("#" + COMPONENT_ID);
      expect($svg.length).to.equal(1);
      expect($svg.hasClass(c.CLASSNAME_COMPONENT)).to.be.true; // Base class
      expect($svg.hasClass("ForwardDownForwardPath")).to.be.true; // Sub class
    });

    it("should output two path elements in the svg", function() {
      var $svg = $("#" + COMPONENT_ID);
      expect($svg.length).to.equal(1);
      expect($svg.children().length).to.equal(2);
      expect($svg.children("path").length).to.equal(2);
    });

    it("should output an arrow path", function() {
      var $svg = $("#" + COMPONENT_ID);
      expect($svg.length).to.equal(1);
      expect($svg.find(".arrowPath").length).to.equal(1);
    });

    it("should output correct coordinates for the arrow path", function() {
      var $svg = $("#" + COMPONENT_ID);
      var $path = $svg.find(".arrowPath");
      expect($svg.length).to.equal(1);
      expect($path.length).to.equal(1);
      expect($path.attr("d")).to.equal("M 288,58 v10 l 10,-5 z");
    });

    it("should make the instance available as data on the $node", function() {
      expect(created.connector.$node.length).to.equal(1);
      expect(created.connector.$node.data("instance")).to.equal(created.connector);
    });
  });
});
