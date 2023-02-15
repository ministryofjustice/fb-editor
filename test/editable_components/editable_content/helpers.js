const { EditableContent } = require('../../../app/javascript/src/editable_components');

const constants = {
  DEFAULT_CONTENT: '[Optional content]',
  HTML_CONTENT: '<h1>Heading</h1><p>This is a paragraph</p><ul><li>Item 1</li><li>Item 2</li></ul>',
  MARKDOWN_CONTENT: '# Heading\n\nThis is a paragraph\n\n- Item 1\n- Item 2\n\n\n',
  UUID: '1234567890',
  EDIT_CLASSNAME: 'active',
}

function createEditableContent(id, config, content) {
    var html = `<form id="${id}-form">
      </form>
      <div id="${id}">${constants.HTML_CONTENT}</div>`;

  $(document.body).append(html);

    $node = $(document).find('#'+id);
    $form = $(document).find('#'+id+'-form');

  var conf = {
      editClassname: constants.EDIT_CLASSNAME,
      form: $form,
      id: id,
      type: 'content',
      data: {
        _uuid: constants.UUID,
      },
      text: {
        default_content: constants.DEFAULT_CONTENT
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

  element = new EditableContent($node, conf);

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
  createEditableContent: createEditableContent,
  teardownView: teardownView
}
