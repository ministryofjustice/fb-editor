const DialogValidation = require("../../../app/javascript/src/component_dialog_validation.js");
const GlobalHelpers = require("../../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "DialogForm",
  CLASSNAME_1: "classname1",
  CLASSNAME_2: "classname2",
  CLASSNAME_ERROR_DIALOG: "dialog-with-errors",
  CLASSNAME_ERROR_MESSAGE: "error",
  TEXT_BUTTON_OK: "This is ok button text",
  TEXT_BUTTON_CANCEL: "This is cancel button text",
  TEXT_ERROR_MESSAGE: "This is an error message",
  REMOTE_TEMPLATE_URL: '/dialog-test.html',
  REMOTE_SUBMIT_URL: '/dialog-submit',
}

const view = {
  text: {
    dialogs: {
      heading: constants.TEXT_HEADING,
      content: constants.TEXT_CONTENT
    }
  }
}


/* Creates a new dialog from only passing in an id and optional config.
 *
 * @id     (String) String used to assign unique ID value.
 * @config (Object) Optional config can be passed in to override the defaults.
 *
 * Returns the following object:
 *
 * {
 *   html: <html used to simulate template rendition of pre-created dialog>
 *   $node: <jQuery enhanced node (before dialog instantiation) of the html>
 *   dialog: <ActivatedDialog instance created>
 *  }
 *
 **/
function createDialog(id, config) {
  var $node = $("#" + id);
  var conf = {
    id: id,
  }

  // Include any passed config items.
  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  return {
    html: $node.get(0).outerHTML,
    $node: $node,
    dialog: new DialogValidation($node, conf)
  }
}



function createRemoteDialog(id, server, config) {
  var conf = {
    id: id,
  }

  // Include any passed config items.
  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  server.respondWith(constants.REMOTE_TEMPLATE_URL, [
          200,
          { "Content-Type": "text/html" },
          `<div class="component-dialog-form"
               id="${id}"
               data-component="FormDialog">
            <form method="get" action="${constants.REMOTE_SUBMIT_URL}">
              <div class="field">
                <label>label text</label>
                <input type="text" value="" />
              </div>
              <button type="submit">OK</button>
            </form>
          </div>`,
        ]);

  var dialog = new DialogValidation(constants.REMOTE_TEMPLATE_URL, config);

  return {
    $node: dialog.$node,
    dialog: dialog,
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 *
 * @id         (String)  Add an identifier to the container DIV to allow more than one at once.
 * @withErrors (Boolean) Adds some error markup to the dialog if true.
 *
 **/
function setupView(id, withErrors) {
  var error = '<span class="' + constants.CLASSNAME_ERROR_MESSAGE  + '">' + constants.TEXT_ERROR_MESSAGE  + '</span>';
  var html = `<div class="component-dialog-form"
                   id="` + id + `"
                   data-component="FormDialog">
                <form method="get" action="${constants.REMOTE_SUBMIT_URL}">
                  <div class="field ` + (withErrors ? constants.CLASSNAME_ERROR_DIALOG : '') + `">
                    <label>label text</label>
                    <span class="hint">` + constants.TEXT_HINT + `</span>
                    ` + (withErrors ? error : '') + `
                    <input type="text" value="` + constants.TEXT_INPUT_VALUE + `" />
                  </div>
                  <input type="submit" value="` + constants.TEXT_BUTTON_OK + `" />
                </form>
              </div>`;

  $(document.body).append(html);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#" + id).remove();
}



module.exports = {
  constants: constants,
  createDialog: createDialog,
  createRemoteDialog: createRemoteDialog,
  setupView: setupView,
  teardownView: teardownView,
  findButtonByText: GlobalHelpers.findButtonByText
}
