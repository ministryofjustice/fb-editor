require("../../setup");

describe("ActivatedMenuActivator", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ActivatedMenuActivator-for-properties-test";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenuActivator(ID);
    });

    after(function() {
      helpers.teardownView(ID);
      created = {};
    });

    it("should return the $node", function() {
      expect(created.item.$node).to.exist;
      expect(created.item.$node.length).to.equal(1);
      expect(created.item.$node.get(0)).to.equal(created.$node.get(0));
    });

    it("should return the menu", function() {
      expect(created.item).to.exist;
      expect(created.item.menu).to.exist;
      expect(created.item.menu.$node.length).to.equal(1);
    });

  });
});
