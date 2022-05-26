const ActivatedFormDialog = require("../../../app/javascript/src/component_activated_form_dialog.js");

const constants = {
  CLASSNAME_ACTIVATOR: "DialogActivator",
  CLASSNAME_COMPONENT: "ActivatedFormDialog",
  CLASSNAME_1: "classname1",
  CLASSNAME_2: "classname2",
  PARENT_ID_ADDITION: "-original-parent",
  TEXT_ACTIVATOR: "This is activator button text",
  TEXT_BUTTON_OK: "This is ok button text",
  TEXT_BUTTON_CANCEL: "This is cancel button text",
  TEXT_HEADING: "General heading text",
  TEXT_CONTENT: "General content text",
  TEXT_ERROR: "This is an error message"
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
  var $node = $("#" + id);
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

  return {
    html: $node.get(0).outerHTML,
    $node: $node,
    dialog: new ActivatedFormDialog($node, conf)
  }
}


/* Deletes any elements added by createDialog()
 * @created (Object) Return value, including Created dialog instance, of createDialog() method.
 **/
function destroyDialog(created) {
  var id = created.$node.attr("id");
  created.dialog.activator.$node.remove();
  created.dialog.$node.remove();
  created.dialog.$container.remove();
  created.dialog = {};
  created = {};
  $("#" + (id + constants.PARENT_ID_ADDITION)).remove();
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 * @id             (String)  String used to assign unique ID value.
 * @withErrors     (Boolean) Used to inject error HTML.
 **/
function setupView(id, withErrors) {
  $(document.body).append(`<script data-component-template="ActivatedFormDialog">
                             <form action="/" method="post">` +
                               (withErrors ? (`<span class="govuk-error-message">` + constants.TEXT_ERROR + `</span>`) : `\n`)
                               + `<input type="text" value="some value here" name="some_input" />
                               <input type="submit" value="` + constants.TEXT_BUTTON_OK + `" />
                             </form>
                           </script>`);

  var $template = $("[data-component-template=ActivatedFormDialog]");
  var html = $template.text();
  var $node = $(html);
  var $originalParent = $("<div></div>");

  // Apply the ID and make sure in DOM
  $originalParent.attr("id", id + constants.PARENT_ID_ADDITION);
  $originalParent.append($node);
  $node.attr("id", id);
  $(document.body).append($originalParent);

}


/* Reset DOM to pre setupView() state
 * @id (String) String used to identify unique parent element.
 **/
function teardownView(id) {
  $("[data-component-template=ActivatedFormDialog]").remove();
  $("#" + (id + constants.PARENT_ID_ADDITION)).remove();
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
  destroyDialog: destroyDialog,
  setupView: setupView,
  teardownView: teardownView,
  findButtonByText: findButtonByText
}
