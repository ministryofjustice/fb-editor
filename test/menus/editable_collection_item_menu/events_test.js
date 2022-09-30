require("../../setup");

describe("EditableCollectionItemMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "EditableCollectionItemMenu-for-methods-test";

  describe("Events", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createEditableCollectionItemMenu(ID);
    });

    afterEach(function() {
      helpers.teardownView(ID);
      created = {};
    });


    /* TEST EVENT: menuselect
     **/
    describe("menuselect", function() {
      it("should call selection() method", function() {
        var originalSelection = c.EditableCollectionItemMenuClass.prototype.selection;
        var $item = created.item.$node.find("li[data-action=" + c.TEXT_ACTION_CLOSE + "]");
        var called = false;

        // Fake selection
        created.item.selection = function() {
          called = true;
        }

        // Activate event.
        expect($item.length).to.equal(1);
        $item.click();

        // Reset selection() back to original.
        created.item.selection = originalSelection;

        expect(called).to.be.true;
      });

    });

  });
});
