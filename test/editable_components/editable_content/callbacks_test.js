require('../../setup');

describe('EditableContent', function() {
  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = 'editable-content-callbacks-test';
  const COMPONENT_CLASSNAME = 'EditableContent';

  describe('Callbacks', function() {
    var created;
    var markdownAdjust = sinon.spy();

    beforeEach(function() {
      created = helpers.createEditableContent(COMPONENT_ID, {
        markdownAdjustment: markdownAdjust,
      });
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    describe('set content()', function() {
      it('should apply markdown adjustments', function() {
        markdownAdjust.resetHistory()
        const updated_content =  '## My new markdown\n\nA paragraph';
        created.instance.content = updated_content;
        expect(markdownAdjust).to.have.been.calledOnceWith(updated_content);
      });

      it('should call emitSaveRequired', function() {
        const spy = sinon.spy(created.instance, "emitSaveRequired");
        const updated_content =  '## My new markdown\n\nA paragraph';
        created.instance.content = updated_content;
        expect(spy).to.have.been.calledOnce;
      });
    });

  });
});
