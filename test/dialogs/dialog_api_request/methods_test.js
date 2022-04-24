require('../../setup');

describe("DialogApiRequest", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;

  describe("Methods", function() {
    // Note: Due to component makeup, the component is actually the
    // parent/container element to original target $node.
    var created;

    before(function(done) {
      var response = `<div class="component component-dialog" id="` + c.COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                      </div>`;

      helpers.setupView();
      created = helpers.createDialog(response, done);
    });

    after(function() {
      helpers.teardownView();
      created.$node.remove();
      created = {};
    });

    it("should close the dialog", function() {
      expect(created.dialog.$node.dialog("isOpen")).to.be.true;
      expect(created.dialog.state).to.equal("open");

      created.dialog.close();
      expect(created.dialog.$node.dialog("isOpen")).to.be.false;
      expect(created.dialog.state).to.equal("closed");
    });

    it("should open the dialog");
    it("should close dialog using standard close button");

    describe("using template buttons", function() {
      it("should close dialog using found template 'cancel' button");
    });

    describe("using generated buttons", function() {
      it("should close dialog using found config.closeOnClickSelector elements");
    });

  });
});
