require('../../setup');
const { EditableContent } = require('../../../app/javascript/src/editable_components');

describe('EditableContent', function() {
  const helpers = require('./helpers');
  const COMPONENT_ID = 'editable-content-events-test';

  describe('Events', function() {
    var spy;

    beforeEach(function() {
      sinon.createSandbox();
      spy = sinon.spy(EditableContent.prototype);
      helpers.createEditableContent(COMPONENT_ID);
    });

    afterEach(function() {
      sinon.restore();
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    it('should call edit on click $output', function() {
      const $output = $(document).find('.EditableContent .output')
      $output.trigger('click');

      expect(spy.edit).to.have.been.calledOnce;
    })

    it('should call edit on focus $output', function() {
      const $output = $(document).find('.EditableContent .output')
      $output.trigger('focus.editablecontent');
      $output.focus();

      expect(spy.edit).to.have.been.calledOnce;
    })

    it('should call update on blur $input', function() {
      const $input = $(document).find('.EditableContent .input')
      $input.trigger('blur');

      expect(spy.update).to.have.been.calledOnce;
    })

  });

});
