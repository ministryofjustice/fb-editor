require('../../setup');
const GlobalHelpers = require('../../helpers');

describe("DialogForm", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "form-dialog-properties-test";

  describe("Properties", function() {
    describe("initialised with node", function() {

      var created;
      before(function() {
        helpers.setupView(COMPONENT_ID);
        created = helpers.createDialog(COMPONENT_ID);
      });

      after(function() {
        helpers.teardownView(COMPONENT_ID);
        created = {};
      });


      it("should make the instance available as data on the $node", function() {
        expect(created.$node.data("instance")).to.equal(created.dialog);
      });

      it("should make the $node public", function() {
        expect(created.dialog.$node).to.exist;
        expect(created.dialog.$node.length).to.equal(1);
        expect(created.dialog.$node.get(0)).to.equal(created.$node.get(0));
      });

      it("should make the $container public", function() {
        expect(created.dialog.$container).to.exist;
        expect(created.dialog.$container.length).to.equal(1);
        expect(created.dialog.$container.get(0).tagName.toLowerCase()).to.equal("div");
      });

      it("should make the $form public", function() {
        expect(created.dialog.$form).to.exist;
        expect(created.dialog.$form.length).to.equal(1);
        expect(created.dialog.$form.get(0).tagName.toLowerCase()).to.equal("form");
        expect(created.dialog.$form.get(0)).to.equal(created.$node.find("form").get(0));
      });

      it("should make the activator public", function() {
        created = helpers.createDialog(COMPONENT_ID, { activator: true,});

        expect(created.dialog.activator).to.exist;
        expect(created.dialog.activator instanceof jQuery).to.be.true;
      })

    });

    describe('initialized with url', function() {
      var created = {};
      var server; 

      before(function() {
        server = GlobalHelpers.createServer(); 
        created = helpers.createRemoteDialog(COMPONENT_ID, server);
      });

      after(function() {
        server.restore();
        helpers.teardownView(COMPONENT_ID);
        created = {};
      });

      it("should make the instance available as data on the $node", function() {
        expect(created.$node.data("instance")).to.equal(created.dialog);
      });

      it("should make the $node public", function() {
        expect(created.dialog.$node).to.exist;
        expect(created.dialog.$node.length).to.equal(1);
        expect(created.dialog.$node.get(0)).to.equal(created.$node.get(0));
      });

      it("should make the $container public", function() {
        expect(created.dialog.$container).to.exist;
        expect(created.dialog.$container.length).to.equal(1);
        expect(created.dialog.$container.get(0).tagName.toLowerCase()).to.equal("div");
      });

      it("should make the $form public", function() {
        expect(created.dialog.$form).to.exist;
        expect(created.dialog.$form.length).to.equal(1);
        expect(created.dialog.$form.get(0).tagName.toLowerCase()).to.equal("form");
        expect(created.dialog.$form.get(0)).to.equal(created.$node.find("form").get(0));
      });

    })
  });
});
