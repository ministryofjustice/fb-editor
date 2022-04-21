require('../../setup');

describe("DialogApiRequest", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;


  describe("Component without buttons", function() {
    // Note: Due to component makeup, the component is actually the
    // parent/container element to original target $node.
    var created;

    before(function(done) {
      var response = `<div class="component component-dialog" id="` + c.COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                      </div>`;

      helpers.setupView();
      created = helpers.createDialog(response, done, {
        closeOnClickSelector: ".button"
      });
    });

    after(function() {
      helpers.teardownView();
      created.$node.remove();
      created = {};
    });

    it("should have the basic HTML in place", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      var $container = $dialog.parent('[role=dialog]');

      expect($dialog.length).to.equal(1);
      expect($dialog.get(0).nodeName.toLowerCase()).to.equal("div");
      expect($dialog.hasClass("component-dialog")).to.be.true;
    });

    it.only("should have the component class name present", function() {
      var $dialog = $("#" + c.COMPONENT_ID);
      var $container = $dialog.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

    it("should apply CSS classnames passed in config", function() {
      var $container = created.$node.parent('[role=dialog]');
      expect($container.hasClass(c.CLASSNAME_1));
      expect($container.hasClass(c.CLASSNAME_2));
    });

    it("should use config.okText as button text", function() {
      var $dialog = created.$node.parent('[role=dialog]');
      var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_OK);
      expect($button).to.exist;
      expect($button.length).to.equal(1);
      expect($button.text()).to.equal(c.TEXT_BUTTON_OK);
    });

    it("should use config.cancelText as button text", function() {
      var $dialog = created.$node.parent('[role=dialog]');
      var $button = helpers.findButtonByText($dialog, c.TEXT_BUTTON_CANCEL);
      expect($button).to.exist;
      expect($button.length).to.equal(1);
      expect($button.text()).to.equal(c.TEXT_BUTTON_CANCEL);
    });

    it("should make the instance available as data on the $node", function() {
      var $container = created.$node.parent('[role=dialog]');
      expect(created.$node.data("instance")).to.equal(created.dialog);
    });

    it("should make the $node public", function() {
      expect(created.dialog.$node).to.exist;
      expect(created.dialog.$node.length).to.equal(1);
      expect(created.dialog.$node.get(0)).to.equal(created.$node.get(0));
    });

    it("should make the activator public", function() {
      expect(created.dialog.activator).to.exist;
      expect(created.dialog.activator.$node).to.exist;
      expect(created.dialog.activator.$node.length).to.equal(1);
      expect(created.dialog.activator.$node.hasClass("DialogActivator")).to.be.true;
    });
  });

});
