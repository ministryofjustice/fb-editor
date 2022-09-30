require("../../setup");

describe("EditableCollectionItemMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "EditableCollectionItemMenu-for-methods-test";

  describe("Methods", function() {
    var created;
    var server;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createEditableCollectionItemMenu(ID);
    });

    afterEach(function() {
      helpers.teardownView(ID);
      created = {};
    });

    /* TEST METHOD: selection()
     **/
    describe("selection()", function() {
      it("should trigger 'EditableCollectionItemMenuSelectionRemove' event when passed 'remove' action", function() {
        var $item = created.$node.find("li[data-action=remove]");
        var called = false;

        $(document).on("EditableCollectionItemMenuSelectionRemove", function() {
                             called = true;
                           });

        // Invoke function via event.
        expect($item.length).to.equal(1);
        created.item.selection(c.FAKE_EVENT, $item);

        // Test
        expect(created.item.selection).to.exist;
        expect(called).to.be.true;
      });

      it("should not trigger 'EditableCollectionItemMenuSelectionRemove' event when passed 'close' action", function() {
        var $item = created.$node.find("li[data-action=close]");
        var called = false;

        $(document).on("EditableCollectionItemMenuSelectionRemove", function() {
                             called = true;
                           });

        // Invoke function via event.
        expect($item.length).to.equal(1);
        $item.click();

        // Test
        expect(created.item.selection).to.exist;
        expect(called).to.be.false;
      });

      it("should trigger close() when passed 'close' action", function() {
        var originalClose = c.EditableCollectionItemMenuClass.prototype.close;
        var $item = created.$node.find("li[data-action=close]");
        var called = false;

        c.EditableCollectionItemMenuClass.prototype.close = function() {
              called = true;
            }

        // Invoke function via event.
        expect($item.length).to.equal(1);
        $item.click();

        // Test
        expect(created.item.selection).to.exist;
        expect(called).to.be.true;

        // Reset previewPage() back to original.
        c.EditableCollectionItemMenuClass.prototype.close = originalClose;
      });
    });


    /* TEST METHOD: close()
     **/
    describe("close()", function() {
      it("should close the diaog", function() {
        created.item.open();
        expect(created.item.container.$node.get(0).style.display).to.not.equal("none");

        created.item.close();
        expect(created.item.container.$node.get(0).style.display).to.equal("none");
      });

      it("should remove 'active' class from activator", function() {
        created.item.open();
        expect(created.item.container.$node.get(0).style.display).to.not.equal("none");
        expect(created.item.activator.$node.hasClass("active")).to.be.true;

        created.item.close();
        expect(created.item.activator.$node.hasClass("active")).to.be.false;
      });
    });

  });
});
