require('../../setup');
const GlobalHelpers = require('../../helpers');

describe("DialogApiRequest", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Properties", function() {

    var created;
    var server;
    var response;

    beforeEach(function() {
      response = `<div class="component component-dialog" id="` + c.COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                      </div>`;

      server = GlobalHelpers.createServer();
      created = helpers.createDialog(response, server);
    });

    afterEach(function() {
      server.restore();
      created.$node.remove();
      created = {};
    });

    it("should make the $node public", function() {
      expect(created.dialog.$node).to.exist;
      expect(created.dialog.$node.length).to.equal(1);
    });

    it("should make the instance available as data on the $node", function() {
      expect(created.dialog.$node.data("instance")).to.equal(created.dialog);
    });

    it("should make the $container public", function() {
      expect(created.dialog.$container).to.exist;
      expect(created.dialog.$container.length).to.equal(1);
      expect(created.dialog.$container.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });
    
    it("should make state public", function() {
      expect(created.dialog.state).to.equal("closed");
    });

    it("should make the activator public", function() {
        created = helpers.createDialog(response, server, { activator: true,});

        expect(created.dialog.activator).to.exist;
        expect(created.dialog.activator instanceof jQuery).to.be.true;
      })
  })
});
