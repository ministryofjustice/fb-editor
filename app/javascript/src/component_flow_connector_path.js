/**
 * FlowConnectorPath Component
 * ----------------------------------------------------
 * Description:
 * Creates elements required for arrows/lines connecting Flow Item in an overview
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');
const CURVE_SPACING = 20;
const CURVE_RIGHT_UP = "a10,10 0 0 0 10,-10";
const CURVE_UP_RIGHT = "a10,10 0 0 1 10,-10";
const CURVE_RIGHT_DOWN = "a10,10 0 0 1 10,10";
const CURVE_DOWN_RIGHT = "a10,10 0 0 0 10,10";
var registry = {}; // Every created FlowConnectorPath is added to this so they can gain knowledge of others, if required.


/* VIEW SPECIFIC COMPONENT:
 * ------------------------
 *
 * @points (Object) Points required for ConnectorPath dimensions {
 *                      lX & lY: 'from' x+y points
 *                      rX & rY: 'to' x+y points
 *                  }
 * @config (Object) Configurations {
 *                      from: Starting $node of the path.
 *                      to: Destination $node of the path.
 *                      $container: jQuery node for appending element.
 *                      space: Number to add before and after start and end points
 *                             (allows for border compensation of existing css)
 *                  }
 **/
class FlowConnectorPath {
  constructor(points, config) {
    var id = utilities.uniqueString("flowconnectorpath-");
    var conf = utilities.mergeObjects({
                 container: $(),
                 boundary: 0
               }, config);

    points = utilities.mergeObjects({
               via_x: 0, // If the connector needs to go via an certain route
               via_y: 0  // you can add x/y coordinates to help route it.
             }, points);

    points.xDifference = utilities.difference(points.from_x, points.to_x);
    points.yDifference = utilities.difference(points.from_y, points.to_y);
    registry[id] = this; // Add to global register

    this._config = conf;
    this._registry = registry;
    this.points = points;
    this.type = conf.type;
    this.$node = buildByType.call(this);
    this.$node.addClass("FlowConnectorPath")
              .addClass(this.type)
              .attr("id", id)
              .attr("data-from", conf.from.attr("id"))
              .attr("data-to", conf.to.attr("id"))
              .data("instance", this);
  }
}


function buildByType(type) {
  var points = this.points;
  var paths = "";

  switch(this.type) {
    case "BackwardPath":
         // TODO...
    case "BackwardUpPath":
         // TODO...
         break;
    case "ForwardPath":
         paths = createPathsForForwardConnector.call(this);
         break;
    case "ForwardUpPath":
         paths = createPathsForForwardUpConnector.call(this);
         break;
    case "ForwardUpForwardDownPath":
         paths = createElementsForForwardUpForwarDownConnector.call(this);
         break;
    case "DownForwardPath":
         paths = createElementsForDownForwardConnector.call(this);
         break;
    case "DownForwardUpPath":
         paths = createElementsForDownForwardUpConnector.call(this);
         break;
    default:
         // Report something should have been set.
         console.log("No path type specified for coordinates: ", JSON.stringify(points).replace("\\", ""));
  }

  return createSvg(paths);
}

function createSvg(paths) {
  const SVG_TAG_OPEN = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">";
  const SVG_TAG_CLOSE = "</svg>";
  var svg = SVG_TAG_OPEN + paths + SVG_TAG_CLOSE;
  return $(svg)
}

function createArrowPath(x, y) {
  return "<path class=\"arrowPath\"  d=\"M " + (x - 10) + "," + (y - 5) + " v10 l 10,-5 z\"></path>";
}

function pathD(/* unlimited */) {
  var path = "M";
  for(var i=0; i<arguments.length; ++i) {
    path += (" " + arguments[i]);
  }
  return path;
}

function xy(x, y) {
  return String(x) + "," + String(y);
}

function createPathsForForwardConnector() {
  var points = this.points;
  var x = points.from_x;
// NOTE: This does not seem to be required ???
// Have temporarily replaced with simplified line below.
// The console output FIRST/SECOND is giving different
// responses, however, so not 100%. Will monitor.
//  var y = (points.from_y < points.to_y ? points.from_y + points.yDifference : points.from_y - points.yDifference);
  var y = points.from_y + points.yDifference;
  var width = "h" + points.xDifference;
  var paths = "<path d=\"" + pathD(xy(x, y), width) + "\"></path>";
  paths += createArrowPath(points.to_x, points.to_y);
  return paths;
}

function createPathsForForwardUpConnector() {
  var points = this.points;
  var vertical = "v-" + (points.yDifference - CURVE_SPACING);
  var horizontal = "h" + (points.xDifference - (CURVE_SPACING * 2));
  var path = "<path d=\"" + pathD(xy(points.from_x, points.from_y), horizontal, CURVE_RIGHT_UP, vertical, CURVE_UP_RIGHT) + "\"></path>";
  return path;
}

function createElementsForForwardUpForwarDownConnector() {
  var points = this.points;
  var vertical1 = "v-" + utilities.difference(0, points.yDifference + points.via_y);
  var vertical2 = "v-" + (points.yDifference - CURVE_SPACING);
var vertical3 = "v" + 100; // TODO... what number should this be and where should it come from?
  var forward1 = "h" + (points.via_y - (CURVE_SPACING * 2));
  var horizontal2 = "h" + (points.xDifference - points.via_y - (CURVE_SPACING));
  var path = "<path d=\"" + pathD(xy(points.from_x, points.from_y), forward1, CURVE_RIGHT_UP, vertical1, CURVE_UP_RIGHT, horizontal2, CURVE_RIGHT_DOWN, vertical3, CURVE_DOWN_RIGHT) + "\"></path>";

  return path;
}


function createElementsForDownForwardConnector() {
  var points = this.points;
  var arrowX = points.from_x + points.xDifference;
  var arrowY = points.from_y + points.yDifference;
  var down = "v" + (points.yDifference - (CURVE_SPACING / 2));
  var forward = "h" + points.xDifference;
  var paths = "<path d=\"" + pathD(xy(points.from_x, points.from_y), down, CURVE_DOWN_RIGHT, forward) + "\"></path>";
  paths += createArrowPath(arrowX, arrowY);
  return paths;
}


function createElementsForDownForwardUpConnector() {
  var points = this.points;
  var arrowX = points.to_x;
  var arrowY = points.to_y;
  var down = "v" + (points.via_y - (CURVE_SPACING / 2)); // Half spacing works but would have expected x1.
  var forward = "h" + (points.xDifference - (CURVE_SPACING * 2.5)); // Not sure why 2.5 and not 3 but it works.
  var up = "v-" + ((utilities.difference(points.via_y, points.to_y) + points.from_y) - CURVE_SPACING);
  var paths = "<path d=\"" + pathD(xy(points.from_x, points.from_y), down, CURVE_DOWN_RIGHT, forward, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT) + "\"></path>";
  paths += createArrowPath(arrowX, arrowY);
  return paths;
}


// Make available for importing.
module.exports = FlowConnectorPath;
