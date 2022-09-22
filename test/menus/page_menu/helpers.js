const PageMenu = require("../../../app/javascript/src/components/menus/page_menu");
const GlobalHelpers = require("../../helpers.js");


const constants = {
  PageMenuClass: PageMenu,

  CLASSNAME_ACTIVATOR: "page-menu-activator-classname",
  CLASSNAME_COMPONENT: "PageMenu",
  EVENT_SELECTION_NAME: "PageMenuTestSelectionEventName",

  ID_CONTAINER_SUFFIX: "-container",
  ID_COMPONENT_SUFFIX: "-component",
  ID_UUID_SUFFIX: "-uuid",

  TEXT_ACTIVATOR: "activated menu activator",
  TEXT_TITLE: "component title",

  TEXT_ITEM_PREVIEW: "Preview page",
  TEXT_ITEM_ADD: "Add page",
  TEXT_ITEM_DELETE: "Delete page",
  TEXT_ITEM_DELETE_API: "Delete page with API check",
  TEXT_ITEM_DELETE_FORM: "Delete page with form",
  TEXT_ITEM_MOVE: "Move page",
  TEXT_ITEM_DEFAULT: "Default action"
}


/* Creates a new PageMenu from only passing in an id.
 *
 * @id     (String) String used to assign unique ID value to test container.
 *
 * Returns the following object:
 *
 * {
 *   $node: <jQuery wrapped HTML element used for PageMenu target>
 *   config: <mix of default config items and ID passed in>
 *   item: <PageMenu instance created>
 *  }
 *
 **/
function createPageMenu(id, config) {
  var $container = $("#" + id + constants.ID_CONTAINER_SUFFIX);
  var $component = $("#" + id + constants.ID_COMPONENT_SUFFIX, $container);
  var conf = GlobalHelpers.mergeConfig({
    activator_text: constants.TEXT_ACTIVATOR,
    id: id,
    preventDefault: true,
    selection_event: constants.EVENT_SELECTION_NAME
  }, config);

  return {
    $node: $component,
    config: conf,
    item: new PageMenu($component, conf)
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
                        <ul id="` + id + constants.ID_COMPONENT_SUFFIX + `"
                            data-activator-text="` + constants.TEXT_ACTIVATOR + `Actions"
                            data-activator-classname="` + constants.CLASSNAME_ACTIVATOR + `"
                            data-title="` + constants.TEXT_TITLE + `"
                            data-uuid="` + id + constants.ID_UUID_SUFFIX + `">
                          <li data-action="preview">
                            <a href="#action1">` + id + constants.TEXT_ITEM_PREVIEW + `</a>
                          </li>
                          <li data-action="add">
                            <a href="#action1">` + id + constants.TEXT_ITEM_ADD + `</a>
                          </li>
                          <li data-action="delete">
                            <a href="#action3">` + id + constants.TEXT_ITEM_DELETE + `</a>
                          </li>
                          <li data-action="delete-api">
                            <a href="#action3">` + id + constants.TEXT_ITEM_DELETE_API + `</a>
                          </li>
                          <li data-action="delete-form">
                            <a href="#action3">` + id + constants.TEXT_ITEM_DELETE_FORM + `</a>
                          </li>
                          <li data-action="move-api">
                            <a href="#action2">` + id + constants.TEXT_ITEM_MOVE + `</a>
                          </li>
                          <li data-action="none">
                            <a href="#action0">` + id + constants.TEXT_ITEM_DEFAULT + `</a>
                          </li>
                        </ul>
                      </div>`);

  $(document.body).append($container);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#" + id + constants.ID_CONTAINER_SUFFIX).remove();
}



module.exports = {
  constants: constants,
  createPageMenu: createPageMenu,
  setupView: setupView,
  teardownView: teardownView
}


