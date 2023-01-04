const FlowItem = require("../../app/javascript/src/component_flow_item.js");
const GlobalHelpers = require("../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "FlowItem",

  FAKE_FLOW_ITEM_CONFIG: {
    next: "id-xyz",
    row: 2,
    column: 3,
    x_in: 100,
    x_out: 150,
    y_in: 20,
    y_out: 500
  },

  TEXT_HEADING: "This is a heading",
  TEXT_CONTENT: "This is some content"
}


/* Creates a new FlowItem from only passing in an id.
 *
 * @id     (String) String used to assign unique ID value.
 *
 * Returns the following object:
 *
 * {
 *   $node: <jQuery wrapped HTML element used for FlowItem target>
 *   config: <mix of default config items and ID passed in>
 *   item: <FlowItem instance created>
 *  }
 *
 **/
function createFlowItem(id) {
  var $node = $("#" + id);
  var conf = GlobalHelpers.mergeConfig(constants.FAKE_FLOW_ITEM_CONFIG, {
    id: id
  });

  return {
    $node: $node,
    config: conf,
    item: new FlowItem($node, conf)
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 *
 * @id (String) Add an identifier to the container DIV to allow more than one at once.
 *
 **/
function setupView(id) {
  var $flowItem = $(`<div class="flow-item" id="` + id + `">
                       <h3>` +
                         constants.TEXT_HEADING +
                      `</h3>
                       <p>` +
                         constants.TEXT_CONTENT +
                      `</p>
                     </div>`);

  $(document.body).append($flowItem);
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#" + id).remove();
}



module.exports = {
  constants: constants,
  createFlowItem: createFlowItem,
  setupView: setupView,
  teardownView: teardownView
}


