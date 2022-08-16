require('../../setup');

describe("Expander", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "expander-for-testing-properties";

  describe("Properties", function() {
    var created;
    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createExpander(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    it("should make the instance available as data on the $node", function() {
      expect(created.expander.$node).to.exist;
      expect(created.expander.$node.length).to.equal(1);
      expect(created.expander.$node.data("instance")).to.eql(created.expander);
    });

    it("should make the $node public", function() {
      expect(created.expander.$node).to.exist;
      expect(created.expander.$node.length).to.equal(1);
      expect(created.expander.$node.attr("id")).to.include("Expander");
    });

    it("should make the $activator public", function() {
      expect(created.expander.$activator).to.exist;
      expect(created.expander.$activator.length).to.equal(1);
      expect(created.expander.$activator.get(0).className).to.equal(c.CLASSNAME_ACTIVATOR);
    });
  });
});
