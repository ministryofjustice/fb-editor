const ActivatedMenu = require("../../../app/javascript/src/components/menus/activated_menu");
const GlobalHelpers = require("../../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "ActivatedMenu",

  ID_CONTAINER_SUFFIX: "-container",
  ID_COMPONENT_SUFFIX: "-component"

}


/* Creates a new ActivatedMenu from only passing in an id.
 *
 * @id     (String) String used to assign unique ID value to test container.
 *
 * Returns the following object:
 *
 * {
 *   $node: <jQuery wrapped HTML element used for ActivatedMenu target>
 *   config: <mix of default config items and ID passed in>
 *   item: <ActivatedMenu instance created>
 *  }
 *
 **/
function createActivatedMenu(id, config) {
  var $container = $("#" + id + constants.ID_CONTAINER_SUFFIX);
  var $component = $("#" + id + constants.ID_COMPONENT_SUFFIX, $container);
  var conf = GlobalHelpers.mergeConfig({
    id: id
  }, config);

  return {
    $node: $component,
    config: conf,
    item: new ActivatedMenu($component, conf)
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
                        <ul id="` + id + constants.ID_COMPONENT_SUFFIX + `">
                          <li>
                            <span>Item 1a</span>
                            <ul>
                              <li><button id="steven" href="#action1">Item 1b</button></li>
                              <li><a href="#action2">Item 2b</a></li>
                              <li><a href="#action3">Item 3b</a></li>
                            </ul>
                          </li>
                          <li><a href="#action4">Item 2a</a></li>
                          <li><a href="#action5">Item 3a</a></li>
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
  createActivatedMenu: createActivatedMenu,
  setupView: setupView,
  teardownView: teardownView
}


