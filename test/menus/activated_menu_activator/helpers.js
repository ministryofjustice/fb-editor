const ActivatedMenuActivator = require("../../../app/javascript/src/components/menus/activated_menu_activator");
const GlobalHelpers = require("../../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "ActivatedMenuActivator",
  CLASSNAME_APPLIED: "some classnames here",

  ID_CONTAINER_SUFFIX: "-container",
  ID_COMPONENT_SUFFIX: "-component",
  ID_MENU_SUFFIX: "-menu"
}


/* Creates a new ActivatedMenuActivator from only passing in an id.
 *
 * @id (String) String used to assign unique ID value to test container.
 *
 * Returns the following object:
 *
 * {
 *   $node: <jQuery wrapped HTML element used for ActivatedMenuActivator target>
 *   config: <mix of default config items and ID passed in>
 *   item: <ActivatedMenuActivator instance created>
 *  }
 *
 **/
function createActivatedMenuActivator(id, config) {
  var $container = $("#" + id + constants.ID_CONTAINER_SUFFIX);
  var fakeMenu = {
    $node: $("#" + id + constants.ID_MENU_SUFFIX)
  }

  // Construct basic config that could be passed to ActivatedMenuActivator creation.
  var conf = GlobalHelpers.mergeConfig({
    id: id
  }, config);

  var activeMenuActivator = new ActivatedMenuActivator(fakeMenu, conf);

  // ActivatedMenuActivator $node gets placed to just before the menu $node.
  var $component = fakeMenu.$node.prev();
  $component.attr("id", id + constants.ID_COMPONENT_SUFFIX);

  return {
    $node: $component,
    config: conf,
    item: activeMenuActivator
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
  createActivatedMenuActivator: createActivatedMenuActivator,
  setupView: setupView,
  teardownView: teardownView
}


