require('../../setup');

describe('EditableContent', function() {
  const helpers = require('./helpers');
  const COMPONENT_ID = 'editable-content-properties-test';

  describe('Properties', function() {
    var created;

    beforeEach(function() {
      created = helpers.createEditableContent(COMPONENT_ID);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    it('should have an $input property', function() {
      var $input = $('#'+COMPONENT_ID).find('.input');
      expect(created.instance.$input).to.exist;
      expect(created.instance.$input).to.be.an.instanceof($)
      expect(created.instance.$input.length).to.equal(1);
      expect(created.instance.$input).to.eql($input);
    });

    it('should have an $output property', function() {
      var $output = $('#'+COMPONENT_ID).find('.output');
      expect(created.instance.$output).to.exist;
      expect(created.instance.$output).to.be.an.instanceof($)
      expect(created.instance.$output.length).to.equal(1);
      expect(created.instance.$output).to.eql($output);
    });

    it('should have a markdown property', function() {
      expect(created.instance.markdown).to.exist;
    });
  });
});
