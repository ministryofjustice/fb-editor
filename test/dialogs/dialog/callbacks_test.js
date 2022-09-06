require('../../setup');

describe("Dialog", function() {

  const helpers = require("./helpers");
  const c = helpers.constants;
  const COMPONENT_ID = 'dialog-callbacks-test';
  var onOpenCallback = sinon.spy();
  var onCloseCallback = sinon.spy();
  var onReadyCallback = sinon.spy();
  var onConfirmCallback = sinon.spy();

  describe("Callbacks", function() {
    var created;

    beforeEach(function() {
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

    it("should call custom onConfirm when passed in", function() {
      var customConfirmCallback = sinon.spy();
      var $button = $('button[data-node="confirm"]', created.$node);
      created.onConfirm = customConfirmCallback;
      created.open({});

      $button.click();

      expect(customConfirmCallback).to.have.been.called;
      expect(customConfirmCallback).to.have.been.calledWith(created);
    });

  })
});

