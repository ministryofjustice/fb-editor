require('../../setup');

describe("DialogActivator", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Component", function() {

    describe("with $node", function() {
      var created;

      before(function() {
        helpers.setupView();
        created = helpers.createActivator(c.ID_LINK);
      });

      after(function() {
        helpers.teardownView();
        created.$node.remove();
        created = {};
      });

 
     it("should have the basic HTML in place", function() {
        var $activator = $("#" + c.ID_LINK);

        expect($activator.length).to.equal(1);
        expect($activator.get(0).nodeName.toLowerCase()).to.equal("a");
        expect($activator.text()).to.equal(created.$node.text());
        expect($activator.get(0)).to.equal(created.$node.get(0));
      });

      it("should have the component class name present", function() {
        expect(created.$node.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
      });

      it("should apply CSS classnames passed as param", function() {
        expect(created.$node.hasClass(c.CLASSNAME_1));
        expect(created.$node.hasClass(c.CLASSNAME_2));
      });

      it("should expose the $node as public", function() {
        expect(created.activator.$node).to.exist;
        expect(created.activator.$node.length).to.equal(1);
        expect(created.activator.$node.get(0)).to.equal(created.$node.get(0));
      });

      it("should expose instance as data attribute on the $node", function() {
        var $activator = $("#" + c.ID_LINK);
        expect($activator.data("instance")).to.equal(created.activator);
      });

      it("should expose the dialog as public", function() {
        expect(created.activator.dialog).to.exist;
        expect(created.activator.dialog.name).to.equal("fake dialog");
      });

      it("should open the dialog on button click", function() {
        var open = false;
        created.activator.dialog.open = function () {
          open = true;
        }

        expect(open).to.be.false;
        created.activator.$node.click();
        expect(open).to.be.true;
      });
    });


    describe("without $node", function() {
      var created;

      before(function() {
        helpers.setupView();
        created = helpers.createActivator("not-an-element-id", {
                    $target: $("#" + c.ID_TARGET),
                    text: c.TEXT_BUTTON
                  });
      });

      after(function() {
        helpers.teardownView();
        created.$node.remove();
        created = {};
      });


      it("should create activator element if $node not found or passed", function() {
        expect(created.activator).to.exist;
        expect(created.activator.$node.attr("id")).to.not.equal("not-an-element-id");
        expect(created.activator.$node.get(0).nodeName.toLowerCase()).to.equal("button");
      });

      it("should use text passed in config for created activator", function() {
        expect(created.activator).to.exist;
        expect(created.activator.$node.text()).to.equal(c.TEXT_BUTTON);
      });

      it("should add created activator node to DOM", function() {
        var id = "dialog-activator-testing-id-for-without-node-test";
        expect(created.activator).to.exist;
        expect(created.activator.$node.length).to.equal(1);
        created.activator.$node.attr("id", id);
        expect($(document.body).find("#" + id).length).to.equal(1);
      });

      it("should place created node before $target", function() {
        var $target = $("#" + c.ID_TARGET);
        expect($target.length).to.equal(1);
        expect($target.prev().get(0)).to.equal(created.activator.$node.get(0));
      });

    });

  });

});
