require('../../setup');
const GlobalHelpers = require("../../helpers.js");

describe("DialogForm", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-validation-callbacks-test";
  var onOpenCallback = sinon.spy();
  var onCloseCallback = sinon.spy();
  var onReadyCallback = sinon.spy();

  describe("Standard callbacks", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(COMPONENT_ID, true);
      created = helpers.createDialog(COMPONENT_ID, {
        onOpen: onOpenCallback,
        onClose: onCloseCallback,
        onReady: onReadyCallback,
      });
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    // For some reason cannot get this test to register the spy as being called
    it('should call onLoad when respose is recieved');

    it('should call onReady when created', function() {
      expect(onReadyCallback).to.have.been.called;
      expect(onReadyCallback).to.have.been.calledWith(created.dialog);
    });

    /* TEST METHOD: open()
**/
    it("should call onOpen when opened", function() {
      created.dialog.open();
      expect(onOpenCallback).to.have.been.called;
      expect(onOpenCallback).to.have.been.calledWith(created.dialog);
    });


    /* TEST METHOD: close()
**/
    it("should call onClose when closed", function() {
      created.dialog.close();
      expect(onCloseCallback).to.have.been.called;
      expect(onCloseCallback).to.have.been.calledWith(created.dialog);
    });
  });

  describe('Async Submission Callbacks', function() {
    var created;
    var server;

    beforeEach(function() {
      helpers.setupView(COMPONENT_ID, true);
      server = GlobalHelpers.createServer();
    });

    afterEach(function() {
      server.restore;
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    it('should call onSuccess', function() {
      var data = {'key': 'value'};
      var onSuccessCallback = sinon.spy();

      server.respondWith("POST", c.REMOTE_SUBMIT_URL, [
        200,
        { "Content-Type": "application/json"},
        JSON.stringify(data),
      ]);

      created = helpers.createDialog(COMPONENT_ID, {
        remote: true,
        onSuccess: onSuccessCallback,
      });

      created.dialog.submit();
      expect(onSuccessCallback).to.have.been.calledWith(data, created.dialog);
    });


    it('should call onError', function() {
      var data = '<div>error</div>';
      var onErrorCallback = sinon.spy();

      server.respondWith("POST", c.REMOTE_SUBMIT_URL, [
        422,
        { "Content-Type": "text/html"},
        `${data}`,
      ]);

      created = helpers.createDialog(COMPONENT_ID, {
        remote: true,
        onError: onErrorCallback,
      });

      created.dialog.submit();

      expect(onErrorCallback).to.have.been.called;
      // expect(onErrorCallback).to.have.been.calledWithMatch(data, created.dialog);
    });

  });

  describe('Remote Template Callbacks', function() {
    var created = {};
    var server;

    beforeEach(function(){
      server = GlobalHelpers.createServer(); 
    });

    afterEach(function(){
      server.restore();
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    it('should call onLoad', function() {
      var onLoadCallback = sinon.spy();
      
      //console.log(server)

      created = helpers.createRemoteDialog(COMPONENT_ID, server, {
        onLoad: onLoadCallback,
      });


      //console.log(server)

      expect(onLoadCallback).to.have.been.called
      expect(onLoadCallback).to.have.been.calledWith(created.dialog);
    });

    it('should call onReady when created', function() {
      var onLoadCallback = sinon.spy();
      var onReadyCallback = sinon.spy();

      created = helpers.createRemoteDialog(COMPONENT_ID, server, {
        onLoad: onLoadCallback,
        onReady: onReadyCallback,
      });

      expect(onReadyCallback).to.have.been.called;
      expect(onReadyCallback).to.have.been.calledAfter(onLoadCallback);
      expect(onReadyCallback).to.have.been.calledWith(created.dialog);
    });
  });

});
