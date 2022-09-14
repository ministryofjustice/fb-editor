require("../../setup");

describe("ActivatedMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ActivatedMenu-for-methods-test";

  describe("Methods", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenu(ID);
    });

    afterEach(function() {
      helpers.teardownView(ID);
      created = {};
    });

    /* TEST METHOD: open()
     **/
    it("should open the menu by the open() method", function() {
      expect(created.item.container.$node.get(0).style.display).to.equal("none");
      created.item.open();
      expect(created.item.container.$node.get(0).style.display).to.equal("");
    });

    it("should set the state.open to true when open() is activated", function() {
      expect(created.item.state.open).to.be.false;
      created.item.open();
      expect(created.item.state.open).to.be.true;
    });

    it("should add the class 'active' to the activator on open()", function() {
      expect(created.item.state.open).to.be.false;
      created.item.open();
      expect(created.item.activator.$node.hasClass("active")).to.be.true;
    });

    // TODO: Test is on hold because we cannot use jsDom for testing position of elements.
    it("should set the position values passed in open()");


    /* TEST METHOD: close()
     **/
    it("should close the menu by the close() method", function() {
      created.item.open();
      expect(created.item.container.$node.get(0).style.display).to.equal("");

      created.item.close();
      expect(created.item.container.$node.get(0).style.display).to.equal("none");
    });

    it("should set the state.open to false when close() is activated", function() {
      created.item.open();
      expect(created.item.state.open).to.be.true;

      created.item.close();
      expect(created.item.state.open).to.be.false;
    });

    it("should place focus on the activator on close()", function() {
      created.item.open();
      expect(created.item.activator.$node.hasClass("active")).to.be.true;

      created.item.close();
      expect(created.item.activator.$node.hasClass("active")).to.be.true;
      expect(document.activeElement).to.eql(created.item.activator.$node[0]);
    });

    // TODO: Test is on hold because we cannot use jsDom for testing position of elements.
    it("should reset the position values on close()");

    // TODO: Test is on hold because we cannot use jsDom for testing mouse events.
    it("should close the menu on mouseout (not sure if can test)");

  });
});