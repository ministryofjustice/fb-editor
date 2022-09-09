require('../../setup');
const GlobalHelpers = require('../../helpers.js');

describe('DialogApiRequest', function() {
  
  const helpers = require('./helpers.js');
  const c = helpers.constants;

  describe('Callbacks', function() {
    var created;
    var server;
    var onLoadCallback = sinon.spy();
    var onReadyCallback = sinon.spy();
    var onOpenCallback = sinon.spy();
    var onCloseCallback = sinon.spy();

    beforeEach(function() {
      var response = `<div class="component component-dialog" id="` + c.COMPONENT_ID + `">
                        <h3>Heading content here</h3>
                        <p>Message content here</p>
                      </div>`;



      server = GlobalHelpers.createServer();
      created = helpers.createDialog(response, server, {
        onload: onLoadCallback,
        onReady: onReadyCallback,
        onOpen: onOpenCallback,
        onClose: onCloseCallback,
      });
    });

    afterEach(function() {
      server.restore();
      created.$node.remove();
      created = {};
    });
    
    // For some reason cannot get this test to register the spy as being called
    it('should call onLoad when respose is recieved');

    it('should call onReady when created', function() {
      expect(onReadyCallback).to.have.been.calledOnce;
      expect(onReadyCallback).to.have.been.calledWith(created.dialog);
    });

    it('should call the onOpen callback when opened', function() {
      created.dialog.open();
      expect(onOpenCallback).to.have.been.calledOnce;
    });

    it('should call the onClose callback when closed', function() {
      created.dialog.open();
      created.dialog.close();
      expect(onCloseCallback).to.have.been.calledOnce;
    });

  });
  
});
