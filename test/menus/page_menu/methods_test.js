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


    /* TEST METHOD: changeDestination()
     **/
    describe("changeDestination()", function() {
      it("should trigger changeDestination() when passed 'destination' action", function() {
        var originalChangeDestination = c.PageMenuClass.prototype.changeDestination;
        var $item = created.$node.find("li[data-action=destination]");
        var called = false;

        c.PageMenuClass.prototype.changeDestination = function(item) {
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
        c.PageMenuClass.prototype.changeDestination = originalChangeDestination;
      });
    });


    /* TEST METHOD: deleteItem()
     **/
    describe("deleteItem()", function() {
      it("should trigger deleteItem() when passed 'delete' action", function() {
        var originalDeleteItem = c.PageMenuClass.prototype.deleteItem;
        var $item = created.$node.find("li[data-action=delete]");
        var called = false;

        c.PageMenuClass.prototype.deleteItem = function(item) {
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
        c.PageMenuClass.prototype.deleteItem = originalDeleteItem;
      });
    });

  });
});
