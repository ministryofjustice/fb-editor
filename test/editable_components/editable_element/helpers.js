const { EditableElement } = require('../../../app/javascript/src/editable_components');
const GlobalHelpers = require('../../helpers.js');

const constants = {
  EDIT_CLASSNAME: 'editable-editing',
  EDITABLE_DEFAULT_CONTENT: '[default content]',
  EDITABLE_RAW_CONTENT: '  editable content  ',
  EDITABLE_TRIMMED_CONTENT: 'editable content',
}

function createEditableElement(id, config, content) {
  var text = content == undefined ? constants.EDITABLE_RAW_CONTENT : content;
  var html = `<form id="${id}-form">
      </form>
      <div id="${id}" data-default-text="${constants.EDITABLE_DEFAULT_CONTENT}">${text}</div>`;

    $(document).find('body').append(html);

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
    var nodes = document.querySelectorAll(`#${id}, #${id}-form`);
    if(nodes) {
      nodes.forEach( (node) => node.remove() )
    }
}

module.exports = {
  constants: constants,
  createEditableElement: createEditableElement,
  teardownView: teardownView,
}
