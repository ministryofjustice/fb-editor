require("../../setup");

describe("EditableCollectionFieldComponment", function () {
  const helpers = require("./helpers");
  const c = helpers.constants;
  const COMPONENT_ID = "editable-collection-field-component-callbacks-test";

  describe("Callbacks", function () {
    var sandbox;

    beforeEach(function () {
      sandbox = sinon.createSandbox();
    });

    afterEach(function () {
      sandbox.restore();
      helpers.teardownView(COMPONENT_ID);
    });

    it("calls the onCollectionItemClone() callback", function () {
      var spy = sinon.spy();
      var created = helpers.createEditableCollectionFieldComponent(
        COMPONENT_ID,
        {
          onCollectionItemClone: spy,
        },
      );

      expect(spy).to.have.been.calledOnce;
    });

    it("calls the onItemAdd() callback", function () {
      var spy = sinon.spy();
      var created = helpers.createEditableCollectionFieldComponent(
        COMPONENT_ID,
        {
          onItemAdd: spy,
        },
      );

      created.instance.addItem();

      expect(spy).to.have.been.calledOnce;
    });

    it("calls the beforeItemRemove() callback", function () {
      var spy = sinon.spy();
      var created = helpers.createEditableCollectionFieldComponent(
        COMPONENT_ID,
        {
          beforeItemRemove: spy,
        },
      );

      created.instance.removeItem(created.instance.items[1]);

      expect(spy).to.have.been.calledOnce;
    });
  });
});
