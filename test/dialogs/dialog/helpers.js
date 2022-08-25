const Dialog = require("../../../app/javascript/src/component_dialog.js");
const GlobalHelpers = require("../../helpers.js");

const constants = {
  CLASSNAME_COMPONENT: "Dialog",
  CLASSNAME_1: 'class-name-1',
  CLASSNAME_2: 'class-name-2',
  TEXT_HEADING: 'This is the heading',
  TEXT_BUTTON_CONFIRM: 'Ok',
  TEXT_BUTTON_CANCEL: 'Cancel',
  TEXT_CONTENT: 'This is the content',
}

const view = {
  text: {
    dialogs: {
      
    }
  }
}

function createDialog(id, config) {
  var $dialog = $(`<div class="component component-dialog">
          <h3 data-node="heading" class="heading">${constants.TEXT_HEADING}</h3>
          <div data-node="content">${constants.TEXT_CONTENT}</div>
          <div>
            <button data-node="confirm">${constants.TEXT_BUTTON_CONFIRM}</button>
            <button data-node="cancel">${constants.TEXT_BUTTON_CANCEL}</button>
          </div>
        </div>`);
  $dialog.attr('id', id);
  $(document.body).append($dialog);

  var conf = {
    autoOpen: false,
    classes: {
      "ui-dialog": constants.classname_1 + " " + constants.classname_2, 
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
  dialog = new Dialog($dialog, config);
  return dialog;
}

function teardownView(id) {
  $("#" + id).remove();
}

module.exports = {
  constants: constants,
  createDialog: createDialog,
  teardownView: teardownView,
}
