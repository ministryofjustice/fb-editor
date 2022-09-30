require("../../setup");

describe("EditableCollectionItemMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "EditableCollectionItemMenu-for-properties-test";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createEditableCollectionItemMenu(ID);
    });

    after(function() {
      helpers.teardownView(ID);
      created = {};
    });

    it("should return the $node", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.item.$node.get(0)).to.equal(created.$node.get(0));
    });

    it("should make the activator public", function() {
      expect(created.item.activator).to.exist;
    });

    it("should make the container public", function() {
      expect(created.item.container).to.exist;
    });

    it("should make the instance available as data on the $node", function() {
      expect(created.$node.data("instance")).to.exist;
      expect(created.$node.data("instance")).to.equal(created.item);
    });

    it("should return the collectionItem (after selection)", function() {
      expect(created.item.collectionItem).to.exist;
      expect(created.item.collectionItem.id).to.equal(c.FAKE_EDITABLE_COLLECTION_ITEM.id);
    });

    it("should return the selectedItem", function() {
      var $item = created.$node.find("li[data-action]").eq(0);

      expect(created.item.selectedItem).to.be.undefined;
      expect($item.length).to.equal(1);

      created.item.selection(c.FAKE_EVENT, $item); // Doesn't matter what is does but should include setting collectionItem.
      expect(created.item.selectedItem).to.exist;
      expect(created.item.selectedItem.length).to.equal(1);
    });

  });
});
