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

      it("should expose the dialog as public");
      it("should expose the $node as public");
      it("should expose instance as data attribute on the $node");
      it("should open the dialog on button click");
    });


    describe("without $node", function() {
      var created;

      before(function() {
        helpers.setupView();
        created = helpers.createActivator("not-an-element-id", {
                    $target: $("#" + c.ID_LINK),
                    text: c.TEXT_BUTTON
                  });
      });

      after(function() {
        helpers.teardownView();
        created.$node.remove();
        created = {};
      });


      it("should create activator element if $node not found or passed");
      it("should use text passed as param");
      it("should add created node to DOM");
      it("should place created node after/before (??) dialog");

    });

  });

});
