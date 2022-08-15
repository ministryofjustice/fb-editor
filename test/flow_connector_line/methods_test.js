require("../setup");

describe("FlowConnectorLine", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconnectorline-for-testing-methods-container";

  describe("Methods", function() {
    var created;

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorLine(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    /* TEST METHOD:  prop()
     **/

    it("should return overlapAllowed value", function() {
      expect(created.lines[0].prop("overlapAllowed")).to.be.true;
      expect(created.lines[1].prop("overlapAllowed")).to.be.false;
      expect(created.lines[2].prop("overlapAllowed")).to.be.true;
    });

    it("should return x value", function() {
      expect(created.lines[0].prop("x")).to.equal(1451);
      expect(created.lines[1].prop("x")).to.equal(1531);
      expect(created.lines[2].prop("x")).to.equal(1541);
    });

    it("should return y value", function() {
      expect(created.lines[0].prop("y")).to.equal(313);
      expect(created.lines[1].prop("y")).to.equal(303);
      expect(created.lines[2].prop("y")).to.equal(63);
    });

    it("should return length value", function() {
      expect(created.lines[0].prop("length")).to.equal(70);
      expect(created.lines[1].prop("length")).to.equal(230);
      expect(created.lines[2].prop("length")).to.equal(-2);
    });


    /* TEST METHOD:  testOnlySvg()
     **/

    it("should return svg element", function() {
      expect(created.lines[0].testOnlySvg().get(0).tagName).to.equal("svg");
      expect(created.lines[1].testOnlySvg().get(0).tagName).to.equal("svg");
      expect(created.lines[2].testOnlySvg().get(0).tagName).to.equal("svg");
    });

    it("should have component class on element", function() {
      expect(created.lines[0].testOnlySvg().hasClass("FlowConnectorLine")).to.be.true;
      expect(created.lines[1].testOnlySvg().hasClass("FlowConnectorLine")).to.be.true;
      expect(created.lines[2].testOnlySvg().hasClass("FlowConnectorLine")).to.be.true;
    });

    it("should have red stroke for testing path", function() {
      expect(created.lines[0].testOnlySvg().children("path").eq(0).get(0).style.stroke).to.equal("red");
      expect(created.lines[1].testOnlySvg().children("path").eq(0).get(0).style.stroke).to.equal("red");
      expect(created.lines[2].testOnlySvg().children("path").eq(0).get(0).style.stroke).to.equal("red");
    });


  });

});
