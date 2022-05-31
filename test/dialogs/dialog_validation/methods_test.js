require('../../setup');
const GlobalHelpers = require("../../helpers.js");

describe("DialogValidation", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-form-methods-test";


  describe("Methods", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(COMPONENT_ID, true);
      created = helpers.createDialog(COMPONENT_ID, {});
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    /* TEST METHOD: open()
     **/
    it("should open the dialog", function() {
      var $container = created.$node.parents("[role=dialog]");

      // should be closed by default
      expect($container.css("display")).to.equal("none");

      // now test open()
      created.dialog.open();
      expect($container.css("display")).to.not.equal("none");
    });


    /* TEST METHOD: close()
     **/
    it("should close the dialog", function() {
      var $container = created.$node.parents("[role=dialog]");

      // First open and check.
      created.dialog.open();
      expect($container.css("display")).to.not.equal("none");

      // Then see if close() properly changes the CSS value
      created.dialog.close();
      expect($container.css("display")).to.equal("none");
    });


    /* TEST METHOD: isOpen()
     **/
    it("should report false when dialog is closed", function() {
      var $container = created.$node.parents("[role=dialog]");

      // First try to make sure it's open
      created.dialog.close();
      expect($container.css("display")).to.equal("none");

      // Then test the method
      expect(created.dialog.isOpen()).to.be.false;
    });

    it("should report true when dialog is open", function() {
      var $container = created.$node.parents("[role=dialog]");

      // First try to make sure it's open
      created.dialog.open();
      expect($container.css("display")).to.not.equal("none");

      // Then test the method
      expect(created.dialog.isOpen()).to.be.true;
    });
    
    /* TEST METHOD: submit()
    **/
    it('should submit the form syncronously', function() {
      var submitted = false;

      created.dialog.$form.on('submit', (e) => {
        submitted = true;
      });

      created.dialog.submit();
      expect(submitted).to.be.true;
      expect(created.dialog.isOpen()).to.be.false;
    });

    describe('Async Form', function() {
      var created;
      var server;

      beforeEach(function() {
        server = GlobalHelpers.createServer();
      });

      afterEach(function() {
        server.restore;
        helpers.teardownView(COMPONENT_ID);
        created = {};
      });
  
      it('should submit the form asynchronously', function() {
        var data = {'key': 'value'};
        var successCallback = sinon.spy();
 
        server.respondWith("POST", c.REMOTE_SUBMIT_URL, [
          200,
          { "Content-Type": "application/json"},
          JSON.stringify(data),
        ]);

        created = helpers.createDialog(COMPONENT_ID, {
          remote: true,
          onSuccess: successCallback,
        });

        created.dialog.submit();

        expect(successCallback).to.have.been.calledWith(data);
   
      });
    });

  });
});
