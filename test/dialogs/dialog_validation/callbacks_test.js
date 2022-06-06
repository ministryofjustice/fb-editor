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

    it('should call onReady when created', function() {
      expect(onReadyCallback).to.have.been.called;
      expect(onReadyCallback).to.have.been.calledWith(created.dialog);
    });

    /* TEST METHOD: open()
**/
    it("should open the dialog", function() {
      created.dialog.open();
      expect(onOpenCallback).to.have.been.called;
      expect(onOpenCallback).to.have.been.calledWith(created.dialog);
    });


    /* TEST METHOD: close()
**/
    it("should close the dialog", function() {
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
    var onLoadCallback;
    var onReadyCallback;

    before(function() {
      server = GlobalHelpers.createServer(); 
    });

    after(function() {
      server.restore();
      helpers.teardownView(COMPONENT_ID);
    });

    beforeEach(function(){
      onLoadCallback = sinon.spy();
      onReadyCallback = sinon.spy();

      created = helpers.createRemoteDialog(COMPONENT_ID, server, {
        onLoad: onLoadCallback,
        onReady: onReadyCallback,
      });
    });

    afterEach(function(){
      onLoadCallback = null;
      onReadyCallback = null;
      created = {};
    });

    it('should call onLoad', function() {
      expect(onLoadCallback).to.have.been.called
      expect(onLoadCallback).to.have.been.calledWith(created.dialog);
    });

    it('should call onReady when created', function() {
      expect(onReadyCallback).to.have.been.called;
      expect(onReadyCallback).to.have.been.calledAfter(onLoadCallback);
      expect(onReadyCallback).to.have.been.calledWith(created.dialog);

    });
  });

});
