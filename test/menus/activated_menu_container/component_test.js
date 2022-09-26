require("../../setup");

describe("ActivatedMenuContainer", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ActivatedMenuContainer-for-component-test";

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenuContainer(ID);
    });

    after(function() {
      helpers.teardownView(ID);
      created = {};
    });

    it("should have the basic HTML in place", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).tagName.toLowerCase()).to.equal("div");
      expect(created.$node.attr("id")).to.equal(ID + c.ID_COMPONENT_SUFFIX);
    });

    it("should have the component class name present", function() {
      expect(created.$node.length).to.equal(1);
      expect(created.$node.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

    it("should give access to instance from data stored on $node", function() {
      expect(created.$node.length).to.equal(1);
      expect(created.$node.data("instance")).to.equal(created.item);
    });

  });
});
