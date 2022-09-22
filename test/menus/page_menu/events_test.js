require("../../setup");

describe("PageMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "PageMenu-for-methods-test";

  describe("Events", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createPageMenu(ID);
    });

    afterEach(function() {
      helpers.teardownView(ID);
      created = {};
    });


    /* TEST EVENT: menuselect
     **/
    describe("menuselect", function() {
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

      it("should trigger deleteItemApi() when passed 'delete' action", function() {
        var originalDeleteItemApi = c.PageMenuClass.prototype.deleteItemApi;
        var $item = created.$node.find("li[data-action=delete-api]");
        var called = false;

        c.PageMenuClass.prototype.deleteItemApi = function(item) {
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
        c.PageMenuClass.prototype.deleteItemApi = originalDeleteItemApi;
      });

      it("should trigger deleteItemForm() when passed 'delete' action", function() {
        var originalDeleteItemForm = c.PageMenuClass.prototype.deleteItemForm;
        var $item = created.$node.find("li[data-action=delete-form]");
        var called = false;

        c.PageMenuClass.prototype.deleteItemForm = function(item) {
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
        c.PageMenuClass.prototype.deleteItemForm = originalDeleteItemForm;
      });

      it("should trigger moveItemApi() when passed 'delete' action", function() {
        var originalMoveItemApi = c.PageMenuClass.prototype.moveItemApi;
        var $item = created.$node.find("li[data-action=move-api]");
        var called = false;

        c.PageMenuClass.prototype.moveItemApi = function(item) {
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
        c.PageMenuClass.prototype.moveItemApi = originalMoveItemApi;
      });

      it("should trigger link() when passed an unfound action", function() {
        var originalLink = c.PageMenuClass.prototype.link;
        var $item = created.$node.find("li[data-action=none]");
        var called = false;

        c.PageMenuClass.prototype.link = function(item) {
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
        c.PageMenuClass.prototype.link = originalLink;
      });
    });

  });
});
