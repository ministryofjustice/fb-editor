require('../setup');

describe('EditableTextFieldComponent', function() {
  const {EditableTextFieldComponent} = require('../../app/javascript/src/editable_components');
  const EDITABLE_INPUT_ID = 'editable-input-id';
  const EDITABLE_LABEL_TEXT = 'editable label';
  const EDITABLE_HINT_TEXT = 'editable hint';
  const EDITABLE_CLASSNAME = 'editable-classname';
  const EDITABLE_UUID = '1234567890'

  var $node, $form, component;

  beforeEach(function() {
    var html = `<form id="editableForm">
      </form>
      <div id="editableTextFieldComponent">
        <label class="editable-label">${EDITABLE_LABEL_TEXT}</label>
        <div class="editable-hint">${EDITABLE_HINT_TEXT}</div>
        <input type="text" />
      </div>`;

    $(document.body).append(html);

    $node = $(document).find('#editableTextFieldComponent');
    $form = $(document).find('#editableForm');

    component = new EditableTextFieldComponent($node, {
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

  /*
   * This component inherits all functionality from EditableComponentBase
   * so there isn't a lot to test here
   */
  describe('Component', function() {
    it('should be given the correct CSS class', function() {
      expect(component.$node.hasClass('EditableTextFieldComponent')).to.be.true;
    })
  })
})
