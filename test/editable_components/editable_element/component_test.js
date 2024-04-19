require('../../setup');

describe('EditableElement', function() {

  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = 'editable-element-component-test';
  const COMPONENT_CLASSNAME = 'EditableElement';

  describe('Component', function() {
    var created;

    beforeEach(function() {
      created = helpers.createEditableElement(COMPONENT_ID);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    it('should add the child span element', function() {
      var $element = $('#'+COMPONENT_ID).find('span');
      expect($element.length).to.equal(1);
    });


    it('should add the contentEditable attribute', function() {
      var $element = $(`#${COMPONENT_ID} > span`);
      expect($element.attr('contenteditable')).to.equal('true');
    });

    it('should add the textbox role', function() {
      var $element = $(`#${COMPONENT_ID} > span`);
      expect($element.attr('role')).to.equal('textbox');

    });

    it('should add the component class name', function() {
      var $element = $(`#${COMPONENT_ID} > span`);
      expect($element.hasClass(COMPONENT_CLASSNAME)).to.be.true
    });


  });
});
