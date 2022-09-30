require("../../setup");

describe("ConnectionMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ConnectionMenu-for-methods-test";

  describe("Methods", function() {
    var created;
    var server;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createConnectionMenu(ID);
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


    /* TEST METHOD: changeDestination()
     **/
    describe("changeDestination()", function() {
      it("should open a DialogForm component", function() {
        var $dialog = $(".DialogForm", document.body);

        // No dialog should exist
        expect($dialog.length).to.equal(0);

        // DialogForm should be created when changeDestination() called.
        created.item.changeDestination(created.$node.find("[data-action=" + c.TEXT_ACTION_DESTINATION + "]"));
        $dialog = $(".DialogForm", document.body);
        expect($(".DialogForm", document.body).length).to.equal(1);

        // clean up
        $dialog.remove();
      });
    });


    /* TEST METHOD: reconnectConfirmation()
     *
     * Note: At time of writing there wasn't an available working example of this
     *       functionality, so the HTML (menu item) has been based on other items
     *       and assumed to be correct. In testing, however, it appears the related
     *       function expects data-url="some/url" attribute from the <li> element,
     *       and not from the (more expected?) first-child <a> href value. To cope
     *       with that expectation, the passed element will have the first-child
     *       href value added to it.
     *
     * Also: We're only checking a form has been added to the <body> content by
     *       the utilities.post function within the reconnectConfirmation()
     *       function as we do not care whether a server call works or not.
     *
     **/
    describe("reconnectConfirmation()", function() {
      it("should post to reconnect-confirmation url", function() {
        var $item = created.$node.find("[data-action=" + c.TEXT_ACTION_RECONNECT + "]");
        var url = $item.find("> a").attr("href") + "-reconnect-confimation-test";
        var uuid = "xyz-some-uuid-value";
        var $form, $input;

        $item.data("url", url);
        $item.data("destination-uuid", uuid);

        created.item.reconnectConfirmation($item);
        $form = $(document.body).find("form[action='" + url + "']");
        $input = $form.find("[name=destination_uuid]");

        expect($form.length).to.equal(1);
        expect($input.length).to.equal(1);
        expect($input.val()).to.equal(uuid);

        // Clean up
        $form.remove();
      });
    });

  });
});
