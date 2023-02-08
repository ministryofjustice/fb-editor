
require('../setup');

describe('EditableGroupFieldComponent', function() {
  const {EditableGroupFieldComponent} = require('../../app/javascript/src/editable_components');
  const EDITABLE_INPUT_ID = 'editable-input-id';
  const EDITABLE_LABEL_TEXT = 'editable label';
  const EDITABLE_HINT_TEXT = 'editable hint';
  const EDITABLE_CLASSNAME = 'editable-classname';
  const EDITABLE_UUID = '1234567890'

  var $node, $form, component;

  beforeEach(function() {
    var html = `<form id="editableForm">
      </form>
      <div id="editableGroupFieldComponent">
        <label class="editable-label">${EDITABLE_LABEL_TEXT}</label>
        <div class="editable-hint">${EDITABLE_HINT_TEXT}</div>
        <input type="text" />
      </div>`;

    $(document.body).append(html);

    $node = $(document).find('#editableGroupFieldComponent');
    $form = $(document).find('#editableForm');

    component = new EditableGroupFieldComponent($node, {
        editClassname: EDITABLE_CLASSNAME,
        form: $form,
        id: EDITABLE_INPUT_ID,
        type: 'editable-type',
        data: {
          _uuid: EDITABLE_UUID
        },
        selectorDisabled: 'input',
        selectorElementLabel: '.editable-label',
        selectorElementHint: '.editable-hint',
      }
    );
  });

  afterEach(function() {
    $node.remove();
    $form.remove();
    $node = $form = component = undefined;
  });

  describe('Methods', function() {
    describe('content()', function() {
      it('should save the label element to data.legend property', function() {
        component.content = component._elements;

        expect(component.data).to.eql({
          _uuid: EDITABLE_UUID,
          legend: EDITABLE_LABEL_TEXT,
          hint: EDITABLE_HINT_TEXT
        });

      });
    });
  });

  describe('Component', function() {
    it('should be given the correct CSS class', function() {
      expect(component.$node.hasClass('EditableGroupFieldComponent')).to.be.true;
    })
  })
});
