require("../../setup");

describe("PageMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "PageMenu-for-component-test";

  describe("Component", function() {
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createPageMenu(ID);
    });

    after(function() {
      helpers.teardownView(ID);
      created = {};
    });


    it("should have the basic HTML in place", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).tagName.toLowerCase()).to.equal("ul");
      expect(created.$node.attr("id")).to.equal(ID + c.ID_COMPONENT_SUFFIX);
      expect(created.$node.find("li").length).to.equal(4);
    });

    it("should have the component class name present", function() {
      var $componentBody = created.$node;
      var $componentContainer = created.$node.parent();

      expect($componentBody.length).to.equal(1);
      expect($componentContainer.length).to.equal(1);
      expect($componentContainer.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

    it("should make the instance accessible from data attached to the element", function() {
      expect(created.$node.length).to.equal(1);
      expect(created.$node.data("instance")).to.equal(created.item);
    });

  });
});
