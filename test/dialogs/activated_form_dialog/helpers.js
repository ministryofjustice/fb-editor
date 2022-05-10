
const ActivatedFormDialog = require("../../../app/javascript/src/component_activated_form_dialog.js");

const constants = {
  CLASSNAME_ACTIVATOR: "DialogActivator",
  CLASSNAME_COMPONENT: "ActivatedFormDialog",
  CLASSNAME_1: "classname1",
  CLASSNAME_2: "classname2",
  TEXT_ACTIVATOR: "This is activator button text",
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
 *   dialog: <ActivatedFormDialog instance created>
 *  }
 *
 **/
function createDialog(id, config) {
  var $template = $("[data-component-template=ActivatedFormDialog]");
  var html = $template.text();
  var $node = $(html);
  var conf = {
    classes: constants.CLASSNAME_1 + " " + constants.CLASSNAME_2,
    id: id,
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

  // Add new $node to DOM
  $(document.body).append($node);

  // Apply the ID
  $node.attr("id", id);
  return {
    html: html,
    $node: $node,
    dialog: new ActivatedFormDialog($node, conf)
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 **/
function setupView() {
  var template = `<script type="text/html" data-component-template="ActivatedFormDialog">
                    <form class="component component-dialog" action="/" method="post">
                      <h3 data-node="heading">General heading here</h3>
                      <p data-node="content">General message here</p>
                      <input type="text" value="some value here" name="some_input" />
                      <input type="submit" value="` + constants.TEXT_BUTTON_OK + `" />
                    </form>
                  </script>`;

  $(document.body).append(template);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView() {
  $("[data-component-template=ActivatedFormDialog]").remove();
}


/* Due to jQueryUI Dialog we cannot identify the added buttons
 * (they have no class, etc) but we can loop over all buttons
 * to match text we seek to get a 'best guess' type of test.
 **/
function findButtonByText($dialog, text) {
  var $buttons = $dialog.find(".ui-button");
  var $button;
  $buttons.each(function() {
    var $this = $(this);
    if($this.text() == text) {
      $button = $this;
      return false;
    }
  });
  return $button;
}


module.exports = {
  constants: constants,
  createDialog: createDialog,
  setupView: setupView,
  teardownView: teardownView,
  findButtonByText: findButtonByText
}
