require('../../setup');

describe("Dialog", function() {
  
  const helpers = require("./helpers");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-properties-test";

  describe('Properties', function(){
    var created;

    beforeEach(function(){
      created = helpers.createDialog(COMPONENT_ID);
    });

    afterEach(function(){
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });
    
    it("should make the instance available as data on the $node", function() {
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.data("instance")).to.eql(created);
    });

    it("should make the $node public", function() {
      var created = $("#" + COMPONENT_ID).data("instance");
      expect(created.$node).to.exist;
      expect(created.$node.length).to.equal(1);
      expect(created.$node.attr("id")).to.equal(COMPONENT_ID);
    });

    it("should make the $container public", function() {
      expect(created.$container).to.exist;
      expect(created.$container.length).to.equal(1);
      expect(created.$container.get(0).tagName.toLowerCase()).to.equal("div");
    });

    it("should make state public", function() {
      expect(created.state).to.equal("closed");
    })

    it("should make content public", function() {
      expect(created.content.heading.text()).to.eql(c.TEXT_HEADING);
      expect(created.content.content.html()).to.eql(c.TEXT_CONTENT);
      expect(created.content.confirm.text()).to.eql(c.TEXT_BUTTON_CONFIRM);
      expect(created.content.cancel.text()).to.eql(c.TEXT_BUTTON_CANCEL);
    });

    it("should set the content", function() {
      created.content = {
        heading: 'Custom Heading',
        content: 'Custom Content',
        confirm: 'Sure Thing',
        cancel: 'Nah',
      };
      
      expect(created.content.heading.text()).to.eql('Custom Heading');
      expect(created.content.content.html()).to.eql('Custom Content');
      expect(created.content.confirm.text()).to.eql('Sure Thing');
      expect(created.content.cancel.text()).to.eql('Nah');
    });

    it("should make the activator public", function() {
        created = helpers.createDialog(COMPONENT_ID, { activator: true,});

        expect(created.activator).to.exist;
        expect(created.activator instanceof jQuery).to.be.true;
      })
  });
});
