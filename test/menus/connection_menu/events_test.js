require("../../setup");

describe("ConnectionMenu", function() {
    const helpers = require("./helpers.js");
    const c = helpers.constants;
    const ID = "ConnectionMenu-for-methods-test";

    function testSelectionCalled(instance, selector) {
        var originalSelection = c.ConnectionMenuClass.prototype.selection;
        var $item = instance.$node.find(selector);
        var called = false;

        // Fake selection
        instance.selection = function() {
            called = true;
        }

        // Activate event.
        $item.click();

        // Reset selection() back to original.
        instance.selection = originalSelection;

        return called;
    }

    function testActionCalled(instance, selector, func) {
        var originalAction = c.ConnectionMenuClass.prototype[func];
        var $item = instance.$node.find(selector);
        var called = false;

        // Fake selection
        instance[func] = function() {
            called = true;
        }

        // Activate event.
        $item.click();

        // Reset selection() back to original.
        instance[func] = originalAction;

        return called;
    }


    describe("Events", function() {
        var created;

        beforeEach(function() {
            helpers.setupView(ID);
            created = helpers.createConnectionMenu(ID);
        });

        afterEach(function() {
            helpers.teardownView(ID);
            created = {};
        });


        /* TEST EVENT: menuselect
         **/
        describe("menuselect", function() {
            // link
            it("should call the selection method when menuselect is triggered with action 'link'", function() {
                var called = testSelectionCalled(created.item, "li[data-action=" + c.TEXT_ACTION_LINK + "]");
                expect(called).to.be.true;
            });

            it("should trigger link() when passed the link action", function() {
                var called = testActionCalled(created.item, "li[data-action=" + c.TEXT_ACTION_LINK + "]", "link");
                expect(called).to.be.true;
            });

            // destination
            it("should call the selection method when menuselect is triggered with action 'destination'", function() {
                var called = testSelectionCalled(created.item, "li[data-action=" + c.TEXT_ACTION_DESTINATION + "]");
                expect(called).to.be.true;
            });

            it("should trigger changeDestination() when passed an 'destination' action", function() {
                var called = testActionCalled(created.item, "li[data-action=" + c.TEXT_ACTION_DESTINATION + "]", "changeDestination");
                expect(called).to.be.true;
            });

            // reconnect-confirmation
            it("should call the selection method when menuselect is triggered with action 'reconnect-confirmation'", function() {
                var called = testSelectionCalled(created.item, "li[data-action=" + c.TEXT_ACTION_RECONNECT + "]");
                expect(called).to.be.true;
            });

            it("should trigger reconnectConfirmation() when passed an 'reconnect-confirmation' action", function() {
                var called = testActionCalled(created.item, "li[data-action=" + c.TEXT_ACTION_RECONNECT + "]", "reconnectConfirmation");
                expect(called).to.be.true;
            });

            // default
            it("should call the selection method when menuselect is triggered with unknown action", function() {
                var called = testSelectionCalled(created.item, "li[data-component-type=" + c.TEXT_PAGE_TYPE_TEXT + "]");
                expect(called).to.be.true;
            });

            it("should trigger addPage() by default (when no action passed)", function() {
                var called = testActionCalled(created.item, "li[data-component-type=" + c.TEXT_PAGE_TYPE_TEXT + "]", "addPage");
                expect(called).to.be.true;
            });
        });

    });
});
