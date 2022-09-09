require('../../setup');

describe('Dialog', function() {

  const helpers = require('./helpers.js');
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-component-test";

  describe('Component', function() {
    var created;

    beforeEach(function() {
      created = helpers.createDialog(COMPONENT_ID, helpers.dialogTemplate);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {}
    });

    it('should have the basic HTML in place', function() {
      var $dialog = $("#" + COMPONENT_ID);
      expect(created.$node.length).to.equal(1);
      expect(created.$node.get(0).nodeName.toLowerCase()).to.equal("div");
      expect(created.$node.attr("id")).to.equal(COMPONENT_ID);
      expect(created.$node.hasClass("component-dialog")).to.be.true;
    });

    it("should have the Dialog class name present", function() {
      expect($("#" + COMPONENT_ID).parents(".Dialog").length).to.equal(1);
    });

    it("should contain the default text", function() {
      var $heading = $("[data-node='heading']", created.$node);
      var $content = $("[data-node='content']", created.$node);
      var $confirm = $("[data-node='confirm']", created.$node);
      var $cancel = $("[data-node='cancel']", created.$node);
      
      expect($heading).to.exist;
      expect($heading.length).to.equal(1);

      expect($content).to.exist;
      expect($content.length).to.equal(1);

      expect($confirm).to.exist;
      expect($confirm.length).to.equal(1);

      expect($cancel).to.exist;
      expect($cancel.length).to.equal(1);

      expect($heading.text()).to.equal(c.TEXT_HEADING);
      expect($content.html()).to.equal(c.TEXT_CONTENT);
      expect($confirm.text()).to.equal(c.TEXT_BUTTON_CONFIRM);
      expect($cancel.text()).to.equal(c.TEXT_BUTTON_CANCEL);
    });

    it("should contain custom content when set", function() {
      var $heading = $("[data-node='heading']", created.$node);
      var $content = $("[data-node='content']", created.$node);
      var $confirm = $("[data-node='confirm']", created.$node);
      var $cancel = $("[data-node='cancel']", created.$node);
      
      expect($heading).to.exist;
      expect($heading.length).to.equal(1);

      expect($content).to.exist;
      expect($content.length).to.equal(1);

      expect($confirm).to.exist;
      expect($confirm.length).to.equal(1);

      expect($cancel).to.exist;
      expect($cancel.length).to.equal(1);

      created.open({
        heading: 'Custom Heading',
        content: 'Custom Content',
        confirm: 'Sure Thing',
        cancel: 'Nah',
      });

      expect($heading.text()).to.equal('Custom Heading');
      expect($content.html()).to.equal('Custom Content');
      expect($confirm.text()).to.equal('Sure Thing');
      expect($cancel.text()).to.equal('Nah');
    });
  });

})
