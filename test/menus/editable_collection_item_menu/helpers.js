const EditableCollectionItemMenu = require("../../../app/javascript/src/components/menus/editable_collection_item_menu");
const GlobalHelpers = require("../../helpers.js");

const REMOTE_URL = "/dialog-api-request.html"
const constants = {
  EditableCollectionItemMenuClass: EditableCollectionItemMenu,

  CLASSNAME_ACTIVATOR: "editable-collection-item-menu-activator-classname",
  CLASSNAME_COMPONENT: "EditableCollectionItemMenu",

  FAKE_EDITABLE_COLLECTION_ITEM: {
    id: "i am a fake collection item"
  },

  FAKE_EVENT: {
    preventDefault: function() {}
  },

  ID_CONTAINER_SUFFIX: "-container",
  ID_COMPONENT_SUFFIX: "-component",

  TEXT_ACTIVATOR: "activated menu activator",

  TEXT_ITEM_DELETE: "Delete...",
  TEXT_ACTION_DELETE: "remove",

  TEXT_ITEM_CLOSE: "Close",
  TEXT_ACTION_CLOSE: "close",

  TEXT_API_PATH: "/services/api/path/"
}


/* Creates a new EditableCollectionItemMenu from only passing in an id.
 *
 * @id     (String) String used to assign unique ID value to test container.
 *
 * Returns the following object:
 *
 * {
 *   $node: <jQuery wrapped HTML element used for EditableCollectionItemMenu target>
 *   config: <mix of default config items and ID passed in>
 *   item: <EditableCollectionItemMenu instance created>
 *  }
 *
 **/
function createEditableCollectionItemMenu(id, config) {
  var $container = $("#" + id + constants.ID_CONTAINER_SUFFIX);
  var $component = $("#" + id + constants.ID_COMPONENT_SUFFIX, $container);

  var conf = GlobalHelpers.mergeConfig({
    id: id,
    collectionItem: constants.FAKE_EDITABLE_COLLECTION_ITEM
  }, config);

  return {
    $node: $component,
    config: conf,
    item: new EditableCollectionItemMenu($component, conf)
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 *
 * @id (String) Add an identifier to the container DIV to allow more than one at once.
 *
 **/
function setupView(id) {
  var $container = $(`<div class="activated-menu-test-container" id="` + id + constants.ID_CONTAINER_SUFFIX + `">
                        <ul id="` + id + constants.ID_COMPONENT_SUFFIX + `" class="component-activated-menu">
                          <li data-action="` + constants.TEXT_ACTION_DELETE + `"
                              data-api-path="` + constants.TEXT_API_PATH + `">
                            <span class="destructive">` + constants.TEXT_ITEM_DELETE + `</span>
                          </li>
                          <li data-action="` + constants.TEXT_ACTION_CLOSE + `">
                            <span>` + constants.TEXT_ITEM_CLOSE + `</span>
                          </li>
                        </ul>
                      </div>`);

  $(document.body).append($container);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#" + id + constants.ID_CONTAINER_SUFFIX).remove();
  $("#" + id + constants.ID_COMPONENT_SUFFIX).parent(".EditableCollectionItemMenu").remove();
  $("#" + id + constants.ID_RESPONSE_SUFFIX).parent("[role=dialog]").remove();
}



module.exports = {
  constants: constants,
  createEditableCollectionItemMenu: createEditableCollectionItemMenu,
  setupView: setupView,
  teardownView: teardownView
}


