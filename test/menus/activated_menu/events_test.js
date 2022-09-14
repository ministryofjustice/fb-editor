require("../../setup");

describe("ActivatedMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ActivatedMenu-for-events-test";

  describe("Events", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenu(ID);
    });

    afterEach(function() {
      helpers.teardownView(ID);
      created = {};
    });


    /* TEST EVENT: selection_event
     **/
    it("should activate the config.selection_event on menu item selection", function() {
      var value = 1;
      $(document).on(c.EVENT_SELECTION_NAME, function() {
        value++;
      });

      expect(value).to.equal(1);

      created.item.$node.find("li > :first-child").eq(0).click();
      expect(value).to.equal(2);
    });

  });
});
