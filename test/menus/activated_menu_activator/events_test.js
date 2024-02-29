require("../../setup");

describe("ActivatedMenuActivator", function() {
  const GlobalHelpers = require("../../helpers.js");
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ActivatedMenuActivator-for-events-test";

  function reset(created) {
    created.item.menu.state.open = false;
    created.item.menu.state.focus = false;
    created.item.menu.state.focusLast = false;
    delete created.item.menu.currentActivator;
  }

  describe("Events", function() {
    var created;

    before(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenuActivator(ID);
    });

    after(function() {
      helpers.teardownView(ID);
      created = {};
    });

    afterEach(function() {
      reset(created)
    });


    /* TEST EVENT: focus
     **/
    it("should add class 'active' on focus", function() {
      expect(created.$node.hasClass("active")).to.be.false;
      created.$node.trigger("focus");
      expect(created.$node.hasClass("active")).to.be.true;
      created.$node.removeClass("active"); // manually remove to reset
    });

    /* TEST EVENT: blur
     **/
    it("should remove class 'active' on blur", function() {
      // manually setup the right conditions...
      created.$node.addClass("active");
      expect(created.item.menu.state.open).to.be.false;
      expect(created.$node.hasClass("active")).to.be.true;

      // trigger the event and check what happens...
      created.$node.trigger("blur");
      expect(created.$node.hasClass("active")).to.be.false;
    });

    /* TEST EVENT: click
     **/
    it("should call open menu and set currentActivator on click", function() {
      expect(created.item.menu.state.open).to.be.false;
      expect(created.item.menu.currentActivator).to.equal(undefined);

      created.$node.trigger('mousedown')
      expect(created.item.menu.state.open).to.be.true;
      expect(created.item.menu.currentActivator).to.equal(created.$node.get(0));
    });

    /* TEST EVENT: keydown
     **/
    describe("Keydown", function() {
      beforeEach(function() {
        expect(created.item.menu.state.open).to.be.false;
        expect(created.item.menu.state.focus).to.be.false;
        expect(created.item.menu.state.focusLast).to.be.false;
        expect(created.item.menu.currentActivator).to.equal(undefined);
      });

      it("should call open menu and call menu.focus() method on Enter", function() {
        var event = GlobalHelpers.keyDownEvent("Enter", 13);

        created.$node.get(0).dispatchEvent(event);
        expect(created.item.menu.state.open).to.be.true;
        expect(created.item.menu.state.focus).to.be.true;
        expect(created.item.menu.currentActivator).to.equal(created.$node.get(0));
      });

      it("should call open menu and call menu.focus() method on Space", function() {
        var event = GlobalHelpers.keyDownEvent("Space", 32);

        created.$node.get(0).dispatchEvent(event);
        expect(created.item.menu.state.open).to.be.true;
        expect(created.item.menu.state.focus).to.be.true;
        expect(created.item.menu.currentActivator).to.equal(created.$node.get(0));
      });

      it("should call open menu and call menu.focus() method on ArrowDown", function() {
        var event = GlobalHelpers.keyDownEvent("ArrowDown", 40);

        created.$node.get(0).dispatchEvent(event);
        expect(created.item.menu.state.open).to.be.true;
        expect(created.item.menu.state.focus).to.be.true;
        expect(created.item.menu.currentActivator).to.equal(created.$node.get(0));
      });

      it("should call open menu and call menu.focusLast() method on ArrowDown", function() {
        var event = GlobalHelpers.keyDownEvent("ArrowUp", 38);

        created.$node.get(0).dispatchEvent(event);
        expect(created.item.menu.state.open).to.be.true;
        expect(created.item.menu.state.focusLast).to.be.true;
        expect(created.item.menu.currentActivator).to.equal(created.$node.get(0));
      });

    });

  });
});
