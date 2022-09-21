require("../../setup");

describe("PageMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "PageMenu-for-methods-test";

  describe("Methods", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createPageMenu(ID);
    });

    afterEach(function() {
      helpers.teardownView(ID);
      created = {};
    });

    /* TEST METHOD: selection()
     **/
    describe("selection()", function() {
      it("should trigger previewPage() when passed 'preview' action", function() {
        var originalPreviewPage = c.PageMenuClass.prototype.previewPage;
        var $item = created.$node.find("li[data-action=preview]");
        var called = false;

        c.PageMenuClass.prototype.previewPage = function(item) {
              called = true;
              item.data("tested", true);
            }

        // Invoke function via event.
        $item.click();

        // Test
        expect(created.item.selection).to.exist;
        expect(called).to.be.true;
        expect($item.data("tested")).to.be.true;

        // Reset previewPage() back to original.
        c.PageMenuClass.prototype.previewPage = originalPreviewPage;
      });
    });


    /* TEST METHOD: addPage()
     **/
    describe("addPage()", function() {
      it("should trigger addPage() when passed 'add' action", function() {
        var originalAddPage = c.PageMenuClass.prototype.addPage;
        var $item = created.$node.find("li[data-action=add]");
        var called = false;

        c.PageMenuClass.prototype.addPage = function(item) {
              called = true;
              item.data("tested", true);
            }

        // Invoke function via event.
        $item.click();

        // Test
        expect(created.item.selection).to.exist;
        expect(called).to.be.true;
        expect($item.data("tested")).to.be.true;

        // Reset previewPage() back to original.
        c.PageMenuClass.prototype.addPage = originalAddPage;
      });
    });


    /* TEST METHOD: link()
     **/
    describe("link()");


    /* TEST METHOD: previewPage()
     **/
    describe("previewPage()");


    /* TEST METHOD: addPage()
     **/
    describe("addPage()");


    /* TEST METHOD: changeDestination()
     **/
    describe("changeDestination()");


    /* TEST METHOD: deleteItem()
     **/
    describe("deleteItem()");


    /* TEST METHOD: deleteItemApi()
     **/
    describe("deleteItemApi()");


    /* TEST METHOD: deleteItemForm()
     **/
    describe("deleteItemForm()");


    /* TEST METHOD: moveItemApi()
     **/
    describe("moveItemApi()");

  });
});
