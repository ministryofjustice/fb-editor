require('../../setup');

describe("DialogValidation", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "dialog-validation-callbacks-test";
  var onOpenCalled = false;
  var onCloseCalled = false;
  var onReadyCalled = false;

  describe("Methods", function() {
    var created;

    beforeEach(function() {
      helpers.setupView(COMPONENT_ID, true);
      created = helpers.createDialog(COMPONENT_ID, {
        onOpen: () => { onOpenCalled = true },
        onClose: () => { onCloseCalled = true },
        onReady: () => { onReadyCalled = true },
      });
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = {};
    });

    it('should call onReady when created', function() {
      expect(onReadyCalled).to.be.true;
    });

    /* TEST METHOD: open()
     **/
    it("should open the dialog", function() {
      created.dialog.open();
      expect(onOpenCalled).to.be.true;
    });


    /* TEST METHOD: close()
     **/
    it("should close the dialog", function() {
      created.dialog.close();
      expect(onCloseCalled).to.be.true;
    });
  });
});
