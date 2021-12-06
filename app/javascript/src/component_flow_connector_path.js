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
const CURVE_SPACING = 10;
const CURVE_RIGHT_UP = "a10,10 0 0 0 10,-10";
const CURVE_UP_RIGHT = "a10,10 0 0 1 10,-10";
const CURVE_RIGHT_DOWN = "a10,10 0 0 1 10,10";
const CURVE_DOWN_LEFT = "a10,10 0 0 1 -10,10";
const CURVE_DOWN_RIGHT = "a10,10 0 0 0 10,10";
const CURVE_LEFT_UP = "a10,10 0 0 1 -10,-10";
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
                 top: 0,
                 bottom: 0 // Nonsense number as should be set by calculating height of container and passing in.
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

    addToDOM.call(this);
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
    case "DownForwardDownBackwardUpPath":
         paths = createElementsForDownForwardDownBackwardUpConnector.call(this);
         break;
    case "DownBackwardUpPath":
         paths = createElementsForDownBackwardUpConnector.call(this);
         break;
    default:
         // Report something should have been set.
         console.error("No path type specified for coordinates: ", JSON.stringify(points).replace("\\", ""));
         console.error("Cannot connect %o to %of: ", this._config.from, this._config.to);
  }

  return createSvg(paths);
}

function addToDOM() {
  this._config.container.append(this.$node);
}

function createSvg(paths) {
  const SVG_TAG_OPEN = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">";
  const SVG_TAG_CLOSE = "</svg>";
  var svg = SVG_TAG_OPEN + paths + SVG_TAG_CLOSE;
  return $(svg)
}

function createArrowPath(points) {
  return "<path class=\"arrowPath\" d=\"M " + (points.to_x - 10) + "," + (points.to_y - 5) + " v10 l 10,-5 z\"></path>";
}

function createPath(d) {
  return "<path d=\"" + d + "\"></path>";
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
  var y = points.from_y + points.yDifference;
  var width = "h" + points.xDifference;
  var paths = createPath(pathD(xy(x, y), width));
  paths += createArrowPath(points);
  return paths;
}

function createPathsForForwardUpConnector() {
  var points = this.points;
  var vertical = "v-" + (points.yDifference - CURVE_SPACING);
  var horizontal = "h" + (points.xDifference - (CURVE_SPACING * 2));
  var paths = createPath(pathD(xy(points.from_x, points.from_y), horizontal, CURVE_RIGHT_UP, vertical, CURVE_UP_RIGHT));
  paths += createArrowPath(points);
  return paths;
}

function createElementsForForwardUpForwarDownConnector() {
  var points = this.points;
  var forward1 = "h" + (points.via_x - CURVE_SPACING);
  var up = "v-" + utilities.difference(points.from_y, this._config.top);
  var forward2 = "h" + (points.xDifference - (points.via_x + (CURVE_SPACING * 4)));
  var down = "v" + utilities.difference(this._config.top, points.to_y);
  var paths = createPath(pathD(xy(points.from_x, points.from_y), forward1, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT, forward2, CURVE_RIGHT_DOWN, down, CURVE_DOWN_RIGHT));
  paths += createArrowPath(points);
  return paths;
}


function createElementsForDownForwardConnector() {
  var points = this.points;
  var down = "v" + (points.yDifference - CURVE_SPACING);
  var forward = "h" + points.xDifference;
  var paths = createPath(pathD(xy(points.from_x, points.from_y), down, CURVE_DOWN_RIGHT, forward));
  paths += createArrowPath(points);
  return paths;
}


function createElementsForDownForwardUpConnector() {
  var points = this.points;
  var down = "v" + (utilities.difference(points.from_y, points.via_y) - CURVE_SPACING);
  var forward = "h" + (points.via_x - (CURVE_SPACING * 2));
  var up = "v-" + (utilities.difference(points.via_y, points.to_y) - (CURVE_SPACING * 2));
  var paths = createPath(pathD(xy(points.from_x, points.from_y), down, CURVE_DOWN_RIGHT, forward, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT));
  paths += createArrowPath(points);
  return paths;
}


function createElementsForDownForwardDownBackwardUpConnector() {
  var points = this.points;
  var conf = this._config;
  var down1 = "v" + (utilities.difference(points.from_y, points.via_y) - CURVE_SPACING);
  var forward = "h" + (points.via_x - (CURVE_SPACING * 2));
  var down2 = "v" + (utilities.difference(this._config.bottom, points.via_y) - CURVE_SPACING * 2);
  var backward = "h-" + (points.via_x + utilities.difference(points.from_x, points.to_x) + 4); // +4 is a HACK to fix alignment - not sure why it's out.
  var up = "v-" + ((utilities.difference(this._config.bottom, this._config.top) - points.to_y) - CURVE_SPACING * 2);
  var paths = createPath(pathD(xy(points.from_x, points.from_y), down1, CURVE_DOWN_RIGHT, forward, CURVE_RIGHT_DOWN, down2, CURVE_DOWN_LEFT, backward, CURVE_LEFT_UP, up, CURVE_UP_RIGHT));
  paths += createArrowPath(points);
  return paths;
}


function createElementsForDownBackwardUpConnector() {
  var points = this.points;
  var conf = this._config;
  var forward = "h" + (points.via_x - (CURVE_SPACING * 2));
  var down = "v" + (utilities.difference(points.from_y, this._config.bottom) - (CURVE_SPACING * 2));
  var backward = "h-" + utilities.difference(points.from_x + points.via_x, points.to_x);
  var up = "v-" + (utilities.difference(this._config.bottom, points.from_y) + utilities.difference(points.from_y, points.to_y) - (CURVE_SPACING * 2));
  var paths = createPath(pathD(xy(points.from_x, points.from_y), forward, CURVE_RIGHT_DOWN, down, CURVE_DOWN_LEFT, backward, CURVE_LEFT_UP, up, CURVE_UP_RIGHT));
  paths += createArrowPath(points);
  return paths;
}


// Make available for importing.
module.exports = FlowConnectorPath;
