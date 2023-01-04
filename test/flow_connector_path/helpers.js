const ConnectorPaths = require("../../app/javascript/src/component_flow_connector_path.js");
const GlobalHelpers = require("../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "FlowConnectorPath",
  FAKE_FLOW_ITEM_1: {
    id: "flow-item-1",
    $node: $() // Update in setupView()
    /* Not used properties of a FlowItem component
    next: next,
    row: row,
    column: column,
    coords: {
      x_in: x_in,
      x_out: x_out,
      y: y,
    }
    */
  },
  FAKE_FLOW_ITEM_2: {
    id: "flow-item-2",
    $node: $() // Update in setupView()
  },
  TEXT_CONTENT: "This is some content",
  TEXT_HEADING: "This is a heading"
}


/* Creates a new FlowConnectorPath from only passing in an id and optional config.
 *
 * @id     (String) String used to assign unique ID value.
 * @points (Object) Coordinates for positioning the FlowConnectorPath.
 * @config (Object) Optional config can be passed in to override the defaults.
 *
 * Returns the following object:
 *
 * {
 *   points: <points used to construct the path>
 *   config: <mix of default config items and those passed in>
 *   path: <FlowConnectorPath instance created>
 *  }
 *
 **/
function createFlowConnectorPath(type, id, points, config) {
  var conf = {
    id: id,
    from: constants.FAKE_FLOW_ITEM_1,
    to: constants.FAKE_FLOW_ITEM_2
  }

  // Include any passed config items.
  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  var path = new ConnectorPaths[type](points, conf);
  path.render();

  return {
    points: points,
    config: conf,
    connector: path
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 *
 * @id (String) Add an identifier to the container DIV to allow more than one at once.
 *
 **/
function setupView(id) {
  var $container = $("<div id=\"" + id + "\"></div>");
  var $flowItem_1 = $(`<div class="flow-item" id="` + constants.FAKE_FLOW_ITEM_1.id + `">
                         <h3>` +
                           constants.TEXT_HEADING +
                           constants.FAKE_FLOW_ITEM_1.id +
                        `</h3>
                         <p>` +
                           constants.TEXT_CONTENT +
                           constants.FAKE_FLOW_ITEM_1.id +
                        `</p>
                       </div>`);

  var $flowItem_2 = $(`<div class="flow-item" id="` + constants.FAKE_FLOW_ITEM_2.id + `">
                         <h3>` +
                           constants.TEXT_HEADING +
                           constants.FAKE_FLOW_ITEM_2.id +
                        `</h3>
                         <p>` +
                           constants.TEXT_CONTENT +
                           constants.FAKE_FLOW_ITEM_2.id +
                        `</p>
                       </div>`);

  $container.append($flowItem_1);
  $container.append($flowItem_2);
  $(document.body).append($container);

  constants.FAKE_FLOW_ITEM_1.$node = $flowItem_1;
  constants.FAKE_FLOW_ITEM_2.$node = $flowItem_2;
}


/* Reset DOM to pre setupView() state
 **/
function teardownView(id) {
  $("#" + id).remove();
}



module.exports = {
  constants: constants,
  createFlowConnectorPath: createFlowConnectorPath,
  setupView: setupView,
  teardownView: teardownView
}


