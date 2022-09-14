require("../../setup");

describe("ActivatedMenuActivator", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Component (created $node)", function() {
    const ID = "ActivatedMenuActivator-for-created-component-test";
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenuActivator(ID);
    });

    after(function() {
      helpers.teardownView(ID);
      created = {};
    });

    it("should have the basic HTML in place", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).tagName.toLowerCase()).to.equal("button");
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

  describe("Component (passed $node)", function() {
    const ID = "ActivatedMenuActivator-for-passed-component-test";
    const ID_BUTTON = "passed-button-for-activator";
    var created, $button;

    before(function() {
      $button = $("<button></button>");
      $button.attr("id", ID_BUTTON);
      $(document.body).append($button);

      helpers.setupView(ID);
      created = helpers.createActivatedMenuActivator(ID, {
        activator: $button
      });
    });

    after(function() {
      helpers.teardownView(ID);
      $button.remove();
      created = {};
    });

    it("should have the basic HTML in place", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).tagName.toLowerCase()).to.equal("button");
      expect(created.$node.get(0)).to.equal($button.get(0));
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
