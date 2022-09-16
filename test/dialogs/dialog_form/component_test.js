require('../../setup');
const GlobalHelpers = require("../../helpers.js");

describe("DialogForm", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Component", function() {

    describe("basic", function() {
      const COMPONENT_ID = "dialog-validation-component-test";
      var created;

      before(function() {
        helpers.setupView(COMPONENT_ID);
        created = helpers.createDialog(COMPONENT_ID);
      });

      after(function() {
        helpers.teardownView(COMPONENT_ID);
        created = {};
      });

      it("should have the basic HTML in place", function() {
        var $dialog = $("#" + COMPONENT_ID);
        expect(created.$node.length).to.equal(1);
        expect(created.$node.get(0).nodeName.toLowerCase()).to.equal("div");
        expect(created.$node.attr("id")).to.equal(COMPONENT_ID);
        expect(created.$node.hasClass("component-dialog-form")).to.be.true;
      });

      it("should have the component class name present", function() {
        var $container = created.$node.parent('[role=dialog]');
        expect($container.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
      });

      it("should apply CSS classnames passed in config", function() {
        var $container = created.$node.parent('[role=dialog]');
        expect($container.hasClass(c.CLASSNAME_1)).to.be.true;
        expect($container.hasClass(c.CLASSNAME_2)).to.be.true;
      });

      it("should make the instance available as data on the $node", function() {
        expect(created.$node.data("instance")).to.equal(created.dialog);
      });

      it("should close dialog on click of 'X' (close) button", function() {
        var $button = created.dialog.$container.find(".ui-dialog-titlebar-close");
        // Make sure it's open
        created.dialog.open();
        expect($button).to.exist;
        expect($button.length).to.equal(1);

        $button.click();
        expect(created.dialog.isOpen()).to.be.false;
      });
    });

    describe('with activator', function() {
      const COMPONENT_ID = "dialog-validation-with-activaor-test-component-test";
      var created;

      before(function() {
        helpers.setupView(COMPONENT_ID);
        created = helpers.createDialog(COMPONENT_ID, {activator: true});
      });

      after(function() {
        helpers.teardownView(COMPONENT_ID);
        created = {};
        $(".DialogActivator").remove();
      });

      it('should open the dialog on activator button press', function() {
        created.dialog.close();

        created.dialog.activator.click();
        expect(created.dialog.isOpen()).to.be.true;
      });
    });

    describe("With remote template", function() {
      const COMPONENT_ID = "dialog-validation-with-remote-test-component-test";
      var created;
      var server;

      before(function() {
        server = GlobalHelpers.createServer();
        created = helpers.createRemoteDialog(COMPONENT_ID, server);
      });

      after(function() {
        helpers.teardownView(COMPONENT_ID);
        server.restore;
        created = {};
      });

      it("should have the basic HTML in place", function() {
        var $dialog = $("#" + COMPONENT_ID);
        expect(created.$node.length).to.equal(1);
        expect(created.$node.get(0).nodeName.toLowerCase()).to.equal("div");
        expect(created.$node.attr("id")).to.equal(COMPONENT_ID);
        expect(created.$node.hasClass("component-dialog-form")).to.be.true;
      });

      it("should have the component class name present", function() {
        var $container = created.$node.parent('[role=dialog]');
        expect($container.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
      });

      it("should apply CSS classnames passed in config", function() {
        var $container = created.$node.parent('[role=dialog]');
        expect($container.hasClass(c.CLASSNAME_1));
        expect($container.hasClass(c.CLASSNAME_2));
      });

      it("should make the instance available as data on the $node", function() {
        var $container = created.$node.parent('[role=dialog]');
        expect(created.$node.data("instance")).to.equal(created.dialog);
      });

      it("should close dialog on click of 'X' (close) button", function() {
        var $button = created.dialog.$container.find(".ui-dialog-titlebar-close");
        // Make sure it's open
        created.dialog.open();
        expect($button).to.exist;
        expect($button.length).to.equal(1);

        $button.click();
        expect(created.dialog.isOpen()).to.be.false;
      });
    });

    describe('with remote and activator', function() {
      const COMPONENT_ID = "dialog-validation-with-remote-and-activator-test-component-test";
      var created;
      var server;
  
      before(function() {
        server = GlobalHelpers.createServer();
        created = helpers.createRemoteDialog(COMPONENT_ID, server, {activator: true});
      });

      after(function() {
        helpers.teardownView(COMPONENT_ID);
        server.restore;
        created = {};
        $(".DialogActivator").remove();
      });

      it('should open the dialog on activator button press', function() {
        created.dialog.activator.click();
        expect(created.dialog.isOpen()).to.be.true;
      });
    });

  });
});
