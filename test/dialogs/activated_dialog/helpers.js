const ActivatedDialog = require("../../../app/javascript/src/component_activated_dialog.js");
const GlobalHelpers = require("../../helpers.js");

const constants = {
  CLASSNAME_COMPONENT: "ActivatedDialog",
  CLASSNAME_1: "classname1",
  CLASSNAME_2: "classname2",
  TEXT_BUTTON_OK: "This is ok button text",
  TEXT_BUTTON_CANCEL: "This is cancel button text",
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
  var $template = $("[data-component-template=ActivatedDialog]");
  var html = $template.text();
  var $node = $(html);
  var conf = {
    classes: {
      "ui-dialog": constants.CLASSNAME_1 + " " + constants.CLASSNAME_2,
    },
    onOk: function() {},
    onCancel: function() {},
    onClose: function() {},
    id: id,
    okText: constants.TEXT_BUTTON_OK,
    cancelText: constants.TEXT_BUTTON_CANCEL
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


/* Set up the DOM to include template code for dialog
 * and anything else required.
 **/
function setupView() {
  var template = `<script type="text/html" data-component-template="ActivatedDialog">
                    <div class="component component-dialog">
                      <h3 data-node="heading">General heading here</h3>
                      <p data-node="content">General message here</p>
                    </div>
                  </script>`;

  $(document.body).append(template);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView() {
  $("[data-component-template=ActivatedDialog]").remove();
  $(".DialogActivator").remove();
}



module.exports = {
  constants: constants,
  createDialog: createDialog,
  setupView: setupView,
  teardownView: teardownView,
  findButtonByText: GlobalHelpers.findButtonByText
}
