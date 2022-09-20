require("../../setup");

describe("PageMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "PageMenu-for-properties-test";

  describe("Properties", function() {
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createPageMenu(ID);
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

    it("should return the uuid", function() {
      expect(created.item.uuid).to.exist;
      expect(created.item.uuid).to.equal(ID + c.ID_UUID_SUFFIX);
    });

    it("should return the title", function() {
      expect(created.item.title).to.exist;
      expect(created.item.title).to.equal(c.TEXT_TITLE);
    });

  });
});
