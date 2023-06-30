require('../../setup');

describe('EditableElement', function() {
  const helpers = require('./helpers');
  const COMPONENT_ID = 'editable-element-events-test';

  describe('Events', function() {
    var created;

    beforeEach(function() {
      created = helpers.createEditableElement(COMPONENT_ID);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    // Would love to do this with spies rather than testing effects of the
    // function, but cannot get sinon spies to work here :-(
    it('should call update() on blur', function() {
      var $element = $('#'+COMPONENT_ID);
      $element.text('My new content');
      $element.trigger('blur');
      expect(created.instance.content).to.equal('My new content');
    });

    // Would love to do this with spies rather than testing effects of the
    // function, but cannot get sinon spies to work here :-(
    it('should call focus() on focus.editablecomponent', function() {
      var $element = $('#'+COMPONENT_ID);

      created.$node.trigger('focus');

      expect(document.activeElement).to.equal($element.get(0));
    });

    // not sure we can test this
    it('should paste as plaintext');

    // not sure we can test this
    it('should prevent newlines');

  });

});
