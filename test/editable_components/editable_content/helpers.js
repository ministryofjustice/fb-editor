const { EditableContent } = require('../../../app/javascript/src/editable_components');

const constants = {
  EDITABLE_DEFAULT_CONTENT: '[Optional content]',
  HTML_CONTENT: '<h1>Heading</h1><p>This is a paragraph</p><ul><li>Item 1</li><li>Item 2</li></ul>',
  MARKDOWN_CONTENT: '# Heading\r\n\r\nThis is a paragraph\r\n\r\n* Item 1\r\n* Item 2\r\n',
}

function createEditableContent(id, config, content) {
    var text = content ? content : constants.EDITABLE_RAW_CONTENT;
    var html = `<form id="${id}-form">
      </form>
      <div id="${id}">${HTML_CONTENT}</div>`;

  $(document.body).append(html);

    $node = $(document).find('#'+id);
    $form = $(document).find('#'+id+'-form');

  var conf = {
      editClassname: constants.EDIT_CLASSNAME,
      form: $form,
      id: id,
      type: 'content',
      data: {
        _uuid: '1234567890'
      },
      text: {
        default_content: ''
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
