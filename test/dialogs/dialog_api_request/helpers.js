const DialogApiRequest = require("../../../app/javascript/src/component_dialog_api_request.js");
const GlobalHelpers = require("../../helpers.js");

const constants = {
  CLASSNAME_COMPONENT: "DialogApiRequest",
  CLASSNAME_1: "classname1",
  CLASSNAME_2: "classname2",
  TEXT_BUTTON_OK: "This is ok button text",
  TEXT_BUTTON_CANCEL: "This is cancel button text",
  TEXT_HEADING: "General heading text",
  TEXT_CONTENT: "General content text",
  REMOTE_URL: "/dialog-api-request.html"
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
 * @response (String) HTML string used to mimic server response.
 * @done (Function) Mocha function used for triggering asynchronous action ready.
 * @config (Object) Optional config can be passed in to override the defaults.
 *
 * Returns the following object:
 *
 * {
 *   html: <html used in faked server response>
 *   $node: <jQuery enhanced node (before dialog instantiation) of the faked html server response>
 *   dialog: <ActivatedDialog instance created using faked server response>
 *  }
 *
 **/
function createDialog(response, server, config) {
  var conf = {
    autoOpen: false,
    classes: {
      "ui-dialog": constants.CLASSNAME_1 + " " + constants.CLASSNAME_2,
    },
    buttons: [
      {
        text: constants.TEXT_BUTTON_OK,
        click: function() {
          //console.log("ok clicked");
        }
      }, 
      {
        text: constants.TEXT_BUTTON_CANCEL,
        click: function() {
          //console.log("cancel clicked");
        }
      }
    ]
  }

  // Include any passed config items.
  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  server.respondWith(constants.REMOTE_URL, [
    200,
    { "Content-Type": "text/html" },
    response,
  ])

  var dialog = new DialogApiRequest(constants.REMOTE_URL, conf)

  return {
    html: response,
    $node: $(response), // WARNING! Will not same as will be same element/node as dialog.$node
    dialog: dialog,
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 **/
function setupView() {
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $('#'+id).remove();
  $(".DialogActivator").remove();
  $(".DialogApiRequest").remove();
}


module.exports = {
  constants: constants,
  createDialog: createDialog,
  setupView: setupView,
  teardownView: teardownView,
  findButtonByText: GlobalHelpers.findButtonByText
}
