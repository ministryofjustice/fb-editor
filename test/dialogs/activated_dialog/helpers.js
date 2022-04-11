const ActivatedDialog = require("../../../app/javascript/src/component_activated_dialog.js");

const constants = {
  CLASSNAME_1: "classname1",
  CLASSNAME_2: "classname2",
  TEXT_HEADING: "General heading text",
  TEXT_CONTENT: "General content text"
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
  var html = `<div class="component component-dialog">
                <h3 data-node="heading">General heading here</h3>
                <p data-node="content">General message here</p>
              </div>`;

  var $node = $(html).attr("id", id);
  var conf = {
    classes: constants.CLASSNAME_1 + " " + constants.CLASSNAME_2,
    onOk: function() {},
    onCancel: function() {},
    onClose: function() {}
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
    dialog: new ActivatedDialog($node, conf)
  }
}

module.exports = {
  constants: constants,
  createDialog: createDialog
}
