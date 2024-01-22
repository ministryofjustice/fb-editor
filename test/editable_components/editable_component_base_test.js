require("../setup");

describe("EditableComponentbase", function () {
  const {
    EditableComponentBase,
  } = require("../../app/javascript/src/editable_components");
  const {
    EditableElement,
  } = require("../../app/javascript/src/editable_components");
  const EDITABLE_INPUT_ID = "editable-input-id";
  const EDITABLE_LABEL_TEXT = "editable label";
  const EDITABLE_HINT_TEXT = "editable hint";
  const EDITABLE_CLASSNAME = "editable-classname";
  const EDITABLE_UUID = "1234567890";

  var $node, $form, component;

  beforeEach(function () {
    var html = `<form id="editableForm">
      </form>
      <div id="editableComponent">
        <label class="editable-label">${EDITABLE_LABEL_TEXT}</label>
        <div class="editable-hint">${EDITABLE_HINT_TEXT}</div>
        <input type="text" />
      </div>`;

    $(document.body).append(html);

    $node = $(document).find("#editableComponent");
    $form = $(document).find("#editableForm");

    component = new EditableComponentBase($node, {
      editClassname: EDITABLE_CLASSNAME,
      form: $form,
      id: EDITABLE_INPUT_ID,
      type: "editable-type",
      data: {
        _uuid: EDITABLE_UUID,
      },
      selectorDisabled: "input",
      selectorElementLabel: ".editable-label",
      selectorElementHint: ".editable-hint",
    });
  });

  afterEach(function () {
    $node.remove();
    $form.remove();
    $node = $form = component = undefined;
  });

  describe("Properties", function () {
    it("should make the instance available as data on the $node", function () {
      var instance = component.$node.data("instance");
      expect(instance).to.exist;
      expect(component).to.equal(instance);
    });

    it("should make the $node public", function () {
      expect(component.$node).to.exist;
      expect(component.$node.length).to.equal(1);
      expect(component.$node.get(0)).to.equal(component.$node.get(0));
    });

    it("should have a public data property", function () {
      expect(component.data).to.exist;
      expect(component.data).to.eql({
        _uuid: EDITABLE_UUID,
      });
    });

    it("should have a public (marked private) elements property", function () {
      var $label = $node.find(".editable-label");
      var $hint = $node.find(".editable-hint");

      expect(component._elements).to.exist;
      expect(component._elements).to.have.property("label");
      expect(component._elements).to.have.property("hint");

      expect(component._elements.label).to.be.an.instanceof(EditableElement);
      expect(component._elements.label.$node).to.eql($label);

      expect(component._elements.hint).to.be.an.instanceof(EditableElement);
      expect(component._elements.hint.$node).to.eql($hint);
    });

    it("content property should return the elements data", function () {
      var json = JSON.stringify({
        _uuid: EDITABLE_UUID,
      });

      expect(component.content).to.eql(json);
    });
  });

  describe("Methods", function () {
    describe("save", function () {
      it("should save the contents of elements into component data", function () {
        component.save();

        expect(component.data).to.eql({
          _uuid: EDITABLE_UUID,
          label: EDITABLE_LABEL_TEXT,
          hint: EDITABLE_HINT_TEXT,
        });
      });

      it("should update the data on save", function () {
        var $label = $node.find(".editable-label");
        var $hint = $node.find(".editable-hint");

        component._elements.label.$node.text("Updated Label");
        component._elements.label.update();
        component._elements.hint.$node.text("Updated Hint");
        component._elements.hint.update();

        component.save();

        expect(component.data).to.eql({
          _uuid: EDITABLE_UUID,
          label: "Updated Label",
          hint: "Updated Hint",
        });
      });
    });

    describe("focus", function () {
      it("should focus the first editable element", function () {
        var label = document.querySelector(".editable-label");
        component.focus();

        expect(document.activeElement).to.eql(label);
      });
    });
  });
});
