require('../../setup');

describe('Dialog', function() {

  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = "component-dialog-methods-test";

  describe("Methods", function() {
    var created;

    beforeEach(function() {
      created = helpers.createDialog(COMPONENT_ID);
    });

    afterEach(function() {
      $('#' + COMPONENT_ID).remove();
      created = {};
    });


    describe("Open", function() {
      it('should open the dialog', function() {
        var $parent = created.$node.parents(".Dialog");
        expect($parent).to.exist;
        expect($parent.length).to.equal(1);
        expect($parent.get(0).style.display).to.equal("none");

        created.open();
        expect($parent.get(0).style.display).to.equal("");
      });

      it('should update the state', function() {
          expect(created.state).to.equal('closed');
          created.open();
          expect(created.state).to.equal('open');
      });

      it('should open with the default content', function() {
        created.open();

        expect(created.content.heading.text()).to.eql(c.TEXT_HEADING);
        expect(created.content.content.html()).to.eql(c.TEXT_CONTENT);
        expect(created.content.confirm.text()).to.eql(c.TEXT_BUTTON_CONFIRM);
        expect(created.content.cancel.text()).to.eql(c.TEXT_BUTTON_CANCEL);
      });

      it('should open with custom content', function() {
        created.open({
          heading: 'Custom Heading',
          content: 'Custom Content',
          confirm: 'Sure Thing',
          cancel: 'Nah',
        });
        
        expect(created.content.heading.text()).to.eql('Custom Heading');
        expect(created.content.content.html()).to.eql('Custom Content');
        expect(created.content.confirm.text()).to.eql('Sure Thing');
        expect(created.content.cancel.text()).to.eql('Nah');
      })

      it('should attach the onConfirm callback if provided');
    });

    describe('isOpen', function(){
      it('should report the open state', function() {
        expect(created.isOpen()).to.be.false;
        created.open();
        expect(created.isOpen()).to.be.true;
      });
    })

    describe('Close', function(){
      it("should close dialog on click of 'X' (close) button", function() {
        var $container = created.$node.parents(".Dialog");
        var $button = $(".ui-dialog-titlebar-close", $container);

        expect($container).to.exist;
        expect($container.length).to.equal(1);

        expect($button).to.exist;
        expect($button.length).to.equal(1);

        dialog.open();
        expect($container.get(0).style.display).to.equal("");

        $button.click();
        expect($container.get(0).style.display).to.equal("none");
      });

      it("should close dialog on click of 'cancel' button", function() {
        var $container = created.$node.parents(".Dialog");
        var $button = $('button[data-node="cancel"]');

        expect($container).to.exist;
        expect($container.length).to.equal(1);

        expect($button).to.exist;
        expect($button.length).to.equal(1);

        dialog.open();
        expect($container.get(0).style.display).to.equal("");

        $button.click();
        expect($container.get(0).style.display).to.equal("none");
      });

      it('should update the state', function() {
          var $button = $(".ui-dialog-titlebar-close");

          expect(created.state).to.equal('closed');
          created.open();
          expect(created.state).to.equal('open');
          $button.click();
          expect(created.state).to.equal('closed');
      });
    });
  });
});
