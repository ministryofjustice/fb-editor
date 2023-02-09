require('../../setup');

describe('EditableContent', function() {

  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = 'editable-content-component-test';
  const COMPONENT_CLASSNAME = 'EditableContent';

  describe('Component', function() {
    var created;

    beforeEach(function() {
      created = helpers.createEditableContent(COMPONENT_ID);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    it('should remove the contentEditable attribute', function() {
      var $element = $('#'+COMPONENT_ID);
      expect($element.attr('contenteditable')).to.equal('false');
    });

    it('should add the textbox role', function() {
      var $element = $('#'+COMPONENT_ID);
      expect($element.attr('role')).to.equal('textbox');

    });

    it('should add the component class name', function() {
      var $element = $('#'+COMPONENT_ID);
      expect($element.hasClass(COMPONENT_CLASSNAME)).to.be.true
    });

    it('should create an input textarea', function() {
      var $input = $('#'+COMPONENT_ID).find('.input');
      expect($input).to.exist;
      expect($input.get(0).nodeName.toLowerCase()).to.equal("textarea");
      expect($input.length).to.equal(1);
    });

    it('should create an output container', function() {
      var $output = $('#'+COMPONENT_ID).find('.output');
      expect($output).to.exist;
      expect($output.length).to.equal(1);
    });

    it('should add the content into the output', function() {
      var $output = $('#'+COMPONENT_ID).find('.output');
      expect($output.html()).to.equal(c.HTML_CONTENT)
    });


  });
});
