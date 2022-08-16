require('../../setup');

describe("Expander", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "expander-for-testing-methods";

  describe("Methods", function() {
    var created;
    before(function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createExpander(COMPONENT_ID);
    });

    after(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });


    /* TEST METHOD:  open()
     **/
    describe("Open", function() {
      beforeEach(function() {
        created.expander.open();
      });

      it("should set the state to open", function() {
        expect(created.expander.isOpen()).to.be.true;
      })

      it("should set the aria-expanded attribute", function() {
        var $content = $('#' + COMPONENT_ID);
        expect($content.find('button').attr('aria-expanded')).to.equal("true");
      });

      it("should show the content container", function() {
        expect(created.expander.$node.get(0).style.display).to.equal(""); 
      })
    });


    /* TEST METHOD:  close()
     **/
    describe("Close", function() {
      beforeEach(function() {
        created.expander.open();
        created.expander.close();
      });

      it("should set the state to open", function() {
        expect(created.expander.isOpen()).to.be.false;
      })

      it("should set the aria-expanded attribute", function() {
        var $content = $('#' + COMPONENT_ID);
        expect($content.find('button').attr('aria-expanded')).to.equal("false");
      });

      it("should hide the content container", function() {
        expect(created.expander.$node.get(0).style.display).to.equal("none"); 
      })
    });


    /* TEST METHOD:  toggle()
     **/
    describe("Toggle", function() {
      it("should toggle the open state", function() {
        created.expander.open();
        expect(created.expander.isOpen()).to.be.true;
        created.expander.toggle();
        expect(created.expander.isOpen()).to.be.false;
        created.expander.toggle();
        expect(created.expander.isOpen()).to.be.true;
      });
    });

  });
});
