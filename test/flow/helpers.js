const ConnectorPaths = require("../../app/javascript/src/component_flow_connector_path.js");
const GlobalHelpers = require("../helpers.js");


const constants = {
  CLASSNAME_COMPONENT: "FlowConnectorPath",
  FLOW_ITEM_1_ID: "flow-item-1",
  FLOW_ITEM_2_ID: "flow-item-2",
  TEXT_CONTENT: "This is some content",
  TEXT_HEADING: "This is a heading"
}


/* Creates a new FlowConnectorPath from only passing in an id and optional config.
 *
 * @id     (String) String used to assign unique ID value.
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
function createFlowConnectorPath(id, points, config) {
  var $container = $("#" + id);
  var conf = {
    id: id + "-connector",
    from: {
      id: constants.FLOW_ITEM_1_ID
    },
    to: {
      id: constants.FLOW_ITEM_2_ID
    }
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
    points: points,
    config: config,
    path: new ConnectorPaths.FlowConnectorPath(points, config)
  }
}


/* Set up the DOM to include template code for dialog
 * and anything else required.
 *
 * @id (String) Add an identifier to the container DIV to allow more than one at once.
 *
 **/
function setupView(id) {
  var html = `<div id="` + id + `">
                <div class="flow-item" id="` + constants.FLOW_ITEM_1_ID + `">
                  <h3>` +
                    constants.TEXT_HEADING +
                    constants.FLOW_ITEM_1_ID +
                 `</h3>
                  <p>` +
                    constants.TEXT_CONTENT +
                    constants.FLOW_ITEM_1_ID +
                 `</p>
                </div>
                <div class="flow-item" id="` + constants.FLOW_ITEM_2_ID + `">
                  <h3>` +
                    constants.TEXT_HEADING +
                    constants.FLOW_ITEM_2_ID +
                 `</h3>
                  <p>` +
                    constants.TEXT_CONTENT +
                    constants.FLOW_ITEM_2_ID +
                 `</p>
                </div>
              </div>`;

  $(document.body).append(html);
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


