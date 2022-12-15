require('../../setup');

describe('EditableElement', function() {
  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = 'editable-element-properties-test';

  describe('Properties', function() {
    var created;

    describe('General', function() {
      beforeEach(function() {
        created = helpers.createEditableElement(COMPONENT_ID);
      });

      afterEach(function() {
        helpers.teardownView(COMPONENT_ID);
        created = undefined;
      });

      it("should make the instance available as data on the $node", function() {
        expect(created.$node).to.exist;
        expect(created.$node.length).to.equal(1);
        expect(created.$node.data("instance")).to.equal(created.instance);
      });

      it("should make the $node public", function() {
        var created = $("#" + COMPONENT_ID).data("instance");
        expect(created.$node).to.exist;
        expect(created.$node.length).to.equal(1);
        expect(created.$node.attr("id")).to.equal(COMPONENT_ID);
      });

      it('should set a private _content variable', function() {
        expect(created.instance._content).to.equal(c.EDITABLE_TRIMMED_CONTENT);
      });

      it('should set a private _originalContent variable', function() {
        expect(created.instance._originalContent).to.equal(c.EDITABLE_TRIMMED_CONTENT);
      });

    })

    describe('without default content (required=true))', function() {
      beforeEach(function() {
        created = helpers.createEditableElement(COMPONENT_ID);
      });

      afterEach(function() {
        helpers.teardownView(COMPONENT_ID);
        created = undefined;
      });

      it('should set a private _defaultContent variable', function() {
        expect(created.instance._defaultContent).to.be.undefined;
      });

      it('should set a private _required variable', function() {
        expect(created.instance._required).to.equal(true);
      });

      it('returns the content if content is not empty', function() {
          expect(created.instance.content).to.equal(c.EDITABLE_TRIMMED_CONTENT);
          created.instance.content = 'new content';
          expect(created.instance.content).to.equal('new content');
      });

      it('returns original content if content is default', function() {
        expect(created.instance.content).to.equal(c.EDITABLE_TRIMMED_CONTENT);
        created.instance.content = 'new content';
        expect(created.instance.content).to.equal('new content');
        created.instance.content = '';
        expect(created.instance.content).to.equal(c.EDITABLE_TRIMMED_CONTENT);
      });
    });

    describe('with default content (required=false)', function() {
      beforeEach(function() {
        created = helpers.createEditableElement(COMPONENT_ID, {
          attributeDefaultText: 'defaultText',
        });
      });

      afterEach(function() {
        helpers.teardownView(COMPONENT_ID);
        created = undefined;
      });

      it('should set a private _defaultContent variable', function() {
        expect(created.instance._defaultContent).to.equal(c.EDITABLE_DEFAULT_CONTENT);
      });

      it('should set a private _required variable', function() {
        expect(created.instance._required).to.equal(false);
      });

      it('returns the content if content is not default', function() {
          expect(created.instance.content).to.equal(c.EDITABLE_TRIMMED_CONTENT);
          created.instance.content = 'new content';
          expect(created.instance.content).to.equal('new content');
      });

      it('returns empty string if content is default', function() {
        expect(created.instance.content).to.equal(c.EDITABLE_TRIMMED_CONTENT);
        created.instance.content = c.EDITABLE_DEFAULT_CONTENT;
        expect(created.instance.content).to.equal('');
      });
    });
  });
})
