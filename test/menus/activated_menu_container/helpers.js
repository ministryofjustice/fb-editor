const ActivatedMenuContainer = require("../../../app/javascript/src/components/menus/activated_menu_container");
const GlobalHelpers = require("../../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "ActivatedMenuContainer",
  CLASSNAME_APPLIED: "some classnames here",

  ID_CONTAINER_SUFFIX: "-container",
  ID_COMPONENT_SUFFIX: "-component",
  ID_MENU_SUFFIX: "-menu"
}


/* Creates a new ActivatedMenuContainer from only passing in an id.
 *
 * @id (String) String used to assign unique ID value to test container.
 *
 * Returns the following object:
 *
 * {
 *   $node: <jQuery wrapped HTML element used for ActivatedMenuContainer target>
 *   config: <mix of default config items and ID passed in>
 *   item: <ActivatedMenuContainer instance created>
 *  }
 *
 **/
function createActivatedMenuContainer(id, config) {
  var $container = $("#" + id + constants.ID_CONTAINER_SUFFIX);
  var fakeMenu = {
    $node: $("#" + id + constants.ID_MENU_SUFFIX)
  }

  // Construct basic config that could be passed to ActivateMenu creation.
  var conf = GlobalHelpers.mergeConfig({
    container_classname: constants.CLASSNAME_APPLIED,
    id: id
  }, config);

  var activeMenuContainer = new ActivatedMenuContainer(fakeMenu, conf);

  // ActivatedMenuContainer appends to body in constructor so
  // we're expecting it to be the last child at this moment.
  var $component = $(document.body).children(":last-child");
  $component.attr("id", id + constants.ID_COMPONENT_SUFFIX);

  return {
    $node: $component,
    config: conf,
    item: activeMenuContainer
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 *
 * @id (String) Add an identifier to the container DIV to allow more than one at once.
 *
 **/
function setupView(id) {
  var $container = $(`<div class="activated-menu-container-test-container" id="` + id + constants.ID_CONTAINER_SUFFIX + `">
                        <ul id="` + id + constants.ID_MENU_SUFFIX + `">
                        </ul>
                      </div>`);

  $(document.body).append($container);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#" + id + constants.ID_MENU_SUFFIX).remove();
  $("#" + id + constants.ID_COMPOMENT_SUFFIX).remove();
  $("#" + id + constants.ID_CONTAINER_SUFFIX).remove();
}



module.exports = {
  constants: constants,
  createActivatedMenuContainer: createActivatedMenuContainer,
  setupView: setupView,
  teardownView: teardownView
}


