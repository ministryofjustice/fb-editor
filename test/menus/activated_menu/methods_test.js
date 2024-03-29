require("../../setup");

describe("ActivatedMenu", function() {
  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const ID = "ActivatedMenu-for-methods-test";

  describe("Methods", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(ID);
      created = helpers.createActivatedMenu(ID);
    });

    afterEach(function() {
      helpers.teardownView(ID);
      created = {};
    });

    /* TEST METHOD: open()
     **/
    describe("open()", function() {
      it("should open the menu by the open() method", function() {
        expect(created.item.container.$node.get(0).style.display).to.equal("none");
        created.item.open();
        expect(created.item.container.$node.get(0).style.display).to.equal("");
      });

      it("should set the state.open to true when open() is activated", function() {
        expect(created.item.state.open).to.be.false;
        created.item.open();
        expect(created.item.state.open).to.be.true;
      });

      it("should add the class 'active' to the activator on open()", function() {
        expect(created.item.state.open).to.be.false;
        created.item.open();
        expect(created.item.activator.$node.hasClass("active")).to.be.true;
      });

      // TODO: Test is on hold because we cannot use jsDom for testing position of elements.
      it("should set the position values passed in open()");
    });

    /* TEST METHOD: isOpen()
     **/
    describe("isOpen()", function() {
      it("should return false when menu not open", function() {
        expect(created.item.state.open).to.be.false;
        expect(created.item.isOpen()).to.be.false;
      });

      it("should return true when menu open", function() {
        created.item.state.open = true;
        expect(created.item.isOpen()).to.be.true;

        // reset to closed
        created.item.state.open = false;
      });
    });


    /* TEST METHOD: close()
     **/
    describe("close()", function() {
      it("should close the menu by the close() method", function() {
        created.item.open();
        expect(created.item.container.$node.get(0).style.display).to.equal("");

        created.item.close();
        expect(created.item.container.$node.get(0).style.display).to.equal("none");
      });

      it("should set the state.open to false when close() is activated", function() {
        created.item.open();
        expect(created.item.state.open).to.be.true;

        created.item.close();
        expect(created.item.state.open).to.be.false;
      });

      it("should place focus on the activator on close()", function() {
        created.item.open();
        expect(created.item.activator.$node.hasClass("active")).to.be.true;

        created.item.close();
        expect(created.item.activator.$node.hasClass("active")).to.be.true;
        expect(document.activeElement).to.eql(created.item.activator.$node[0]);
      });

      // TODO: Test is on hold because we cannot use jsDom for testing position of elements.
      it("should reset the position values on close()");

      // TODO: Test is on hold because we cannot use jsDom for testing mouse events.
      it("should close the menu on mouseout (not sure if can test)");
    });


    /* TEST METHOD: closeAllSubmenus()
     **/
    describe("closeAllSubmenus()", function() {
      it("should close (hide) any open submenus", function() {
        var submenus = created.$node.find("ul[role=\"menu\"]");
        expect(submenus.eq(0).length).to.equal(1);
        
        submenus.eq(0).get(0).style.display = "block";
        expect(submenus.eq(0).get(0).style.display).to.equal("block");

        created.item.closeAllSubmenus();
        expect(submenus.eq(0).get(0).style.display).to.equal("none");
      });
    });


    /* TEST METHOD: focus()
     **/
    describe("focus()", function() {
      it("should set (private) currentFocusIndex to last item number when passed a number below zero", function() {
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));

        created.item.focus(-1);
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(3));
      });

      it("should set (private) currentFocusIndex to first item number when passed a number higher than possible", function() {
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));

        created.item.focus(5);
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));
      });

      it("should set (private) currentFocusIndex to item number passed when valid", function() {
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));
        created.item.focus(1);

        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(1));
      });
    });


    /* TEST METHOD: focusNext()
     **/
    describe("focusNext()", function() {
      it("should should increase currentFocusIndex when there's a next item", function() {
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));

        created.item.focusNext();
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(1));
      });
    });


    /* TEST METHOD: focusPrev()
     **/
    describe("focusPrev()", function() {
      it("should should decrease (private) currentFocusIndex when there's a previous item", function() {
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));

        created.item.focus(2);
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(2));

        created.item.focusPrev();
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(1));
      });
    });


    /* TEST METHOD: focusItem()
     **/
    describe("focusItem()", function() {
      it("should should set (private) currentFocusIndex to number of pass item", function() {
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));

        created.item.focusItem(created.item.$items.eq(2));
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(2));
      });
    });


    /* TEST METHOD: focusLast()
     **/
    describe("focusLast()", function() {
      it("should should set currentFocusIndex to number of last item", function() {
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.get(0));

        created.item.focusLast();
        expect(created.item.currentFocusItem.get(0)).to.equal(created.item.$items.last().get(0));
      });
    });

  });
});
