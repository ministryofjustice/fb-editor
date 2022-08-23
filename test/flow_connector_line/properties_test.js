require("../setup");

describe("FlowConnectorLine", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "flowconnectorline-for-testing-properties-container";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createFlowConnectorLine(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });

    it("should return the name", function() {
      expect(created.lines.length).to.equal(3);
      expect(created.lines[0].name).to.equal("forward1");
      expect(created.lines[1].name).to.equal("up");
      expect(created.lines[2].name).to.equal("forward2");
    });

    it("should return the type", function() {
      expect(created.lines.length).to.equal(3);
      expect(created.lines[0].type).to.equal("horizontal");
      expect(created.lines[1].type).to.equal("vertical");
      expect(created.lines[2].type).to.equal("horizontal");
    });

    it("should return the path value", function() {
      expect(created.lines.length).to.equal(3);
      expect(created.lines[0].path).to.equal("h70");
      expect(created.lines[1].path).to.equal("v-230");
      expect(created.lines[2].path).to.equal("h-2");
    });

    it("should return the range", function() {
      expect(created.lines[0].range.length).to.equal(70);
      expect(created.lines[0].range[0]).to.equal(1451);
      expect(created.lines[1].range[0]).to.equal(303);
    });

  });

});
