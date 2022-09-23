require("../../setup");

describe("ActivatedMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ActivatedMenu-for-properties-test";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenu(ID);
    });

    after(function() {
      helpers.teardownView(ID);
      created = {};
    });


    /* TEST PROPERTY: $node
     **/
    it("should return the $node", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.item.$node.get(0)).to.equal(created.$node.get(0));
    });


    /* TEST PROPERTY: activator
     **/
    it("should make the activator public", function() {
      expect(created.item.activator).to.exist;
    });


    /* TEST PROPERTY: container
     **/
    it("should make the container public", function() {
      expect(created.item.container).to.exist;
    });


    /* TEST PROPERTY: instance
     **/
    it("should make the instance available as data on the $node", function() {
      expect(created.$node.data("instance")).to.exist;
      expect(created.$node.data("instance")).to.equal(created.item);
    });


    /* TEST PROPERTY: config
     **/
    it("should expose private field config via a getter", function() {
      expect(created.item.config).to.exist;
      expect(created.item.config.preventDefault).to.exist;
      expect(created.item.config.activator_text).to.equal(c.TEXT_ACTIVATOR);
    });

    it("should not be able to set private config", function() {
      created.item.config = {
        activator_text: "nope"
      };
      expect(created.item.config.activator_text).to.equal(c.TEXT_ACTIVATOR);
    });


    /* TEST PROPERTY: position
     **/
    it("should expose private field position via a getter", function() {
      expect(created.item.position).to.exist;
      expect(created.item.position.my).to.exist;
      expect(created.item.position.my).to.equal("left top");
      expect(created.item.position.at).to.exist;
      expect(created.item.position.at).to.equal("left top");
      expect(created.item.position.of).to.exist;
    });

    it("should not be able set private position", function() {
      created.item.position = {
        my: "bottom right"
      };
      expect(created.item.position.my).to.equal("left top");
    });


    /* TEST PROPERTY: state
     **/
    it("should expose private field state via a getter", function() {
      expect(created.item.state).to.exist;
      expect(created.item.state.open).to.exist;
      expect(created.item.state.open).to.be.false;
    });

    it("should not be able set private state", function() {
      created.item.state = {
        open: true
      };
      expect(created.item.state.open).to.be.false;
    });


    /* TEST PROPERTY: currentFocusItem
     **/
    it("should return current (zero-index) item on initial check", function() {
      expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));
    });

    it("should return currentFocusIndex value of 2 when focus is on third item", function() {
      created.item.focus(2);
      expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(2));
    });
  });
});
