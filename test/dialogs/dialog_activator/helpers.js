const DialogActivator = require("../../../app/javascript/src/component_dialog_activator.js");

const constants = {
  CLASSNAME_COMPONENT: "DialogActivator",
  CLASSNAME_1: "classname1",
  CLASSNAME_2: "classname2",
  ID_LINK: "dialog-activator-link-id-for-test",
  ID_TARGET: "dialog-activator-target-id-for-test",
  TEXT_LINK: "link text",
  TEXT_BUTTON: "activator button text"
}


/* Creates a new DialogActivator from only passing in an id and optional config.
 *
 * @id     (String) String used to assign unique ID value.
 * @config (Object) Optional config can be passed in to override the defaults.
 *
 * Returns the following object:
 *
 * {
 *   html: <html used to simulate template rendition with pre-created activator>
 *   $node: <jQuery enhanced node (before DialogActivator instantiation) of the html>
 *   dialog: <DialogActivator instance created>
 *  }
 *
 **/
function createActivator(id, config) {
  var $node = $("#" + id);
  var html = $node.length ? $node.get(0).outerHTML : "";
  var conf = {
    dialog: { name: "fake dialog", $node: $("<div id=\"fake-dialog\"></div>") },
    classes: constants.CLASSNAME_1 + " " + constants.CLASSNAME_2,
    id: id
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
    html: html,
    $node: $node,
    activator: new DialogActivator($node, conf)
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 **/
function setupView() {
  var html = `<a href="#` + constants.ID_TARGET  + `" id="` + constants.ID_LINK + `">` + constants.TEXT_LINK + `</a>
              <p id="` + constants.ID_TARGET  + `">Something else on the page</p>`;
  $(document.body).append(html);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView() {
  $("#" + constants.ID_LINK).remove();
}


module.exports = {
  constants: constants,
  createActivator: createActivator,
  setupView: setupView,
  teardownView: teardownView
}
