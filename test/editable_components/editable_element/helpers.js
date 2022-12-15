const { EditableElement } = require('../../../app/javascript/src/editable_components');
const GlobalHelpers = require('../../helpers.js');

const constants = {
  EDIT_CLASSNAME: 'editable-editing',
  EDITABLE_DEFAULT_CONTENT: '[default content]',
  EDITABLE_RAW_CONTENT: '  editable content  ',
  EDITABLE_TRIMMED_CONTENT: 'editable content',
}

function createEditableElement(id, config, content) {
    var text = content ? content : constants.EDITABLE_RAW_CONTENT;
    var html = `<form id="${id}-form">
      </form>
      <div id="${id}" data-default-text="${constants.EDITABLE_DEFAULT_CONTENT}">${text}</div>`;

    $(document.body).append(html);

    $node = $(document).find('#'+id);
    $form = $(document).find('#'+id+'-form');

  var conf = {
      editClassname: constants.EDIT_CLASSNAME,
      form: $form,
      id: id,
      type: 'editable-type',
      data: {
        _uuid: '1234567890'
      }
  }
  // include any passed config items.
  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  element = new EditableElement($node, conf);

  return {
    instance: element,
    $node: $node,
    $form: $form,
  }
}

function teardownView(id) {
    $("#" + id).remove();
    $("#" + id + "-form").remove();
}

module.exports = {
  constants: constants,
  createEditableElement: createEditableElement,
  teardownView: teardownView,
}
