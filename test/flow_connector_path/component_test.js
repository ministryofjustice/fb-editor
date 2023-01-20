require("../setup");

describe("FlowConnectorPath", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconnectorpath-for-testing-component-container";
  const COMPONENT_ID = "flowconnectorpath-for-testing-component-connector";

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorPath('FlowConnectorPath', COMPONENT_ID, {
          from_x: 10,
          from_y: 12,
          to_x: 25,
          to_y: 27,
          via_x: 20
        }, {
        container: $("#" + CONTAINER_ID),
        from: c.FAKE_FLOW_ITEM_1,
        to: c.FAKE_FLOW_ITEM_2,
        top: 5,
        bottom: 10
      });

      // Base class FlowConnectorPath does not call build() function from constructor.
      created.connector.render();
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
      expect($svg.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
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
      expect($path.attr("d")).to.equal("M 14,22 v10 l 10,-5 z");
    });

  });
});
