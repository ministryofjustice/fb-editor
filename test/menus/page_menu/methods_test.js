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
      // Note - This function has been tested within the events_test.js file
      //        so there is little need to replicate the testing here.
      it("should trigger the appropriate function based on passed event+item combination");
    });


    /* TEST METHOD: deleteItemApi()
     **/
    describe("deleteItemApi()", function() {
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
    });


    /* TEST METHOD: deleteItemForm()
     **/
    describe("deleteItemForm()", function() {
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
    });


    /* TEST METHOD: moveItemApi()
     **/
    describe("moveItemApi()", function() {
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
    });


    /* TEST METHOD: link()
     **/
    describe("link()", function() {
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
