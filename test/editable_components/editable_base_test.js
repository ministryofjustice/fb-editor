require("../setup");

describe("EditableBase", function() {
  const { EditableBase } = require('../../app/javascript/src/editable_components');

  const EDITABLE_INPUT_ID = 'editable-input-id';
  const EDITABLE_TEXT = 'editable content';
  const EDITABLE_CLASSNAME = 'editable-classname';
  const EDITABLE_UUID = '1234567890'

  var $node, $form, component;

  beforeEach(function() {
    var html = `<form id="editableForm">
      </form>
      <div id="editableElement">${EDITABLE_TEXT}</div>`;

    $(document.body).append(html);

    $node = $(document).find('#editableElement');
    $form = $(document).find('#editableForm');

    component = new EditableBase($node, {
      editClassname: EDITABLE_CLASSNAME,
      form: $form,
      id: EDITABLE_INPUT_ID,
      type: 'editable-type',
      data: {
        _uuid: EDITABLE_UUID
      }
    });
  });

  afterEach(function() {
    $node.remove();
    $form.remove();
    $node = $form = component = undefined;
  })

  describe('Properties', function() {
    it("should make the instance available as data on the $node", function() {
      var instance = component.$node.data("instance");
      expect(instance).to.exist;
      expect(component).to.equal(instance);
    });

    it('should return the elements content', function() {
      expect(component.content).to.equal(EDITABLE_TEXT);
    })

    it("should make the $node public", function() {
      expect(component.$node).to.exist;
      expect(component.$node.length).to.equal(1);
      expect(component.$node.get(0)).to.equal(component.$node.get(0));
    });

    it('should have a config getter', function() {
      expect(component.config).to.exist;
      expect(component.config).to.eql({
        editClassname: EDITABLE_CLASSNAME,
        form: $form,
        id: EDITABLE_INPUT_ID,
        type: 'editable-type',
        data: {
          _uuid: EDITABLE_UUID
        }
      })
    })
  })

  describe('Methods', function(){

    describe('save()', function() {
      it('should update hidden input content', function() {
        $form.prepend('<input type="hidden" name="'+EDITABLE_INPUT_ID+'" value="" />');
        var $input = $form.find('[name="'+EDITABLE_INPUT_ID+'"]');

        component.save();

        expect($input.val()).to.equal(EDITABLE_TEXT);
      });

      it('should add the hidden field if not present', function() {
        var $input = $form.find('[name="'+EDITABLE_INPUT_ID+'"]');
        expect($input.length).to.equal(0);

        component.save();

        $input = $form.find('[name="'+EDITABLE_INPUT_ID+'"]');
        expect($input.length).to.equal(1);
        expect($input.val()).to.equal(EDITABLE_TEXT);
      });
    });

    describe('remove()', function() {
      it('should add a hidden input to the form', function() {
        var $hiddenInput = $form.find('input[name="delete_components[]"]');
        expect($hiddenInput.length).to.equal(0);

        component.remove();

        $hiddenInput = $form.find('input[name="delete_components[]"]');
        expect($hiddenInput.length).to.equal(1);
        expect($hiddenInput.val()).to.equal(EDITABLE_UUID);
      });

      it('should remove input from the form', function() {
        $form.prepend('<input type="hidden" name="'+EDITABLE_INPUT_ID+'" />');

        var $input = $form.find('[name="'+EDITABLE_INPUT_ID+'"]');
        expect($input.length).to.equal(1);

        component.remove();

        $input = $form.find('[name="'+EDITABLE_INPUT_ID+'"]');
        expect($input.length).to.equal(0);
      });
    })

    describe('emitSaveRequired()', function() {
      it('should trigger SaveRequired event on document', function() {
        var eventCount = 0;

        $(document).on('SaveRequired', function() {
          eventCount++;
        });

        component.emitSaveRequired();

        expect(eventCount).to.equal(1);
      });
    });
  });
});
