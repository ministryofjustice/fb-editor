require("../../setup");

describe("PageMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "PageMenu-for-methods-test";

  describe("Methods", function() {
    var created;
    var server;

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
      it("should open a DialogApiRequest component", function() {
        var $element = created.$node.find("[data-action=delete-api]");
        var $dialog;

        expect($element.length).to.equal(1);
        created.item.deleteItemApi($element);

        $dialog = $("#" + ID + c.ID_RESPONSE_SUFFIX);
        expect($dialog.length).to.equal(1);
        expect($dialog.parent(".DialogApiRequest").length).to.equal(1);
      });
    });


    /* TEST METHOD: deleteItemForm()
     **/
    describe("deleteItemForm()", function() {
      it("should open a DialogForm component", function() {
        var $element = created.$node.find("[data-action=delete-form]");
        var $dialog;

        expect($element.length).to.equal(1);
        created.item.deleteItemForm($element);

        $dialog = $("#" + ID + c.ID_RESPONSE_SUFFIX);
        expect($dialog.length).to.equal(1);
        expect($dialog.parent(".DialogForm").length).to.equal(1);
      });
    });


    /* TEST METHOD: moveItemApi()
     **/
    describe("moveItemApi()", function() {
      it("should open a DialogForm component", function() {
        var $element = created.$node.find("[data-action=move-api]");
        var $dialog;

        expect($element.length).to.equal(1);
        created.item.moveItemApi($element);

        $dialog = $("#" + ID + c.ID_RESPONSE_SUFFIX);
        expect($dialog.length).to.equal(1);
        expect($dialog.parent(".DialogForm").length).to.equal(1);
      });
    });


    /* TEST METHOD: link()
     **/
    describe("link()", function() {
      it("should follow the elements natural link/href value", function() {
        var $element = created.$node.find("[data-action=none]");
        global.location = {};

        expect($element.length).to.equal(1);
        expect(location.href).to.equal(undefined);

        created.item.link($element);
        expect(location.href).to.equal($element.find("> a").attr("href"));
      });
    });

  });
});
