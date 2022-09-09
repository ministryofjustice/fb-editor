require('../../setup');

describe("Dialog", function() {

  const helpers = require("./helpers");
  const c = helpers.constants;
  const COMPONENT_ID = 'dialog-callbacks-test';
  var onOpenCallback;
  var onCloseCallback;
  var onReadyCallback;
  var onConfirmCallback;

  describe("Callbacks", function() {
    var created;

    beforeEach(function() {
      onOpenCallback = sinon.spy();
      onCloseCallback = sinon.spy();
      onReadyCallback = sinon.spy();
      onConfirmCallback = sinon.spy();
      created = helpers.createDialog(COMPONENT_ID, {
        onOpen: onOpenCallback,
        onClose: onCloseCallback,
        onReady: onReadyCallback,
        onConfirm: onConfirmCallback,
      });
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });
    
    it('should call onReady when created', function() {
      expect(onReadyCallback).to.have.been.called;
      expect(onReadyCallback).to.have.been.calledWith(created);
    });
    
    it("should call onOpen when opened", function() {
      created.open();
      expect(onOpenCallback).to.have.been.called;
      expect(onOpenCallback).to.have.been.calledWith(created);
    });

    it("should call onClose when closed", function() {
      created.close();
      expect(onCloseCallback).to.have.been.called;
      expect(onCloseCallback).to.have.been.calledWith(created);
    });

    it("should call onConfirm when confirm button is clicked", function() {
      var $button = $('button[data-node="confirm"]', created.$node);
      created.open();

      $button.click();

      expect(onConfirmCallback).to.have.been.called;
      expect(onConfirmCallback).to.have.been.calledWith(created);
    });

    it("should call custom onOpen if set", function() {
      var customCallback = sinon.spy();
      var $button = $('button[data-node="confirm"]', created.$node);
      created.onOpen = customCallback;
      created.open({});

      $button.click();
      
      expect(onOpenCallback).to.not.have.been.called;
      expect(customCallback).to.have.been.called;
      expect(customCallback).to.have.been.calledWith(created);
    });

    it("should call custom onClose if set", function() {
      var customCallback = sinon.spy();
      var $button = $('button[data-node="confirm"]', created.$node);
      created.onClose = customCallback;
      created.open({});

      $button.click();

      expect(onCloseCallback).to.not.have.been.called;
      expect(customCallback).to.have.been.called;
      expect(customCallback).to.have.been.calledWith(created);
    });

    it("should call custom onConfirm if set", function() {
      var customCallback = sinon.spy();
      var $button = $('button[data-node="confirm"]', created.$node);
      created.onConfirm = customCallback;
      created.open({});

      $button.click();

      expect(onConfirmCallback).to.not.have.been.called;
      expect(customCallback).to.have.been.called;
      expect(customCallback).to.have.been.calledWith(created);
    });

    it("should reset custom onOpen on close", function() {
      var customCallback = sinon.spy();
      var $button = $('button[data-node="confirm"]', created.$node);
      created.onOpen = customCallback;
      created.open({});

      $button.click();
      expect(customCallback).to.have.been.calledOnce;
      
      created.close();
      created.open({});

      expect(customCallback).to.have.been.calledOnce;
      expect(onOpenCallback).to.have.been.calledOnce;
    });

    it("should reset custom onClose on close", function() {
      var customCallback = sinon.spy();
      var $button = $('button[data-node="confirm"]', created.$node);
      created.onClose = customCallback;
      created.open({});

      $button.click();
      expect(customCallback).to.have.been.calledOnce;
      
      created.close();
      created.open({});

      expect(customCallback).to.have.been.calledOnce;
      expect(onCloseCallback).to.have.been.calledOnce;
    });

    it("should reset custom onConfirm on close", function() {
      var customCallback = sinon.spy();
      var $button = $('button[data-node="confirm"]', created.$node);
      created.onConfirm = customCallback;
      created.open({});

      $button.click();
      expect(customCallback).to.have.been.calledOnce;
      
      created.close();
      created.open({});
      $button.click();

      expect(customCallback).to.have.been.calledOnce;
      expect(onConfirmCallback).to.have.been.calledOnce;
    });
  })
});

