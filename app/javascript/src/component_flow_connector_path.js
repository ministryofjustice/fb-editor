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
const NUDGE_SPACING = 5;
const CURVE_RIGHT_UP = "a10,10 0 0 0 10,-10";
const CURVE_UP_RIGHT = "a10,10 0 0 1 10,-10";
const CURVE_RIGHT_DOWN = "a10,10 0 0 1 10,10";
const CURVE_DOWN_LEFT = "a10,10 0 0 1 -10,10";
const CURVE_DOWN_RIGHT = "a10,10 0 0 0 10,10";
const CURVE_LEFT_UP = "a10,10 0 0 1 -10,-10";



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

    // Public
    this.points = points;
    this.id = id;

    // Private
    this._config = conf;
    this._path = "";
  }

  build(path) {
    this.$node = createSvg(createPath(this._path) + createArrowPath(this.points));
    this.$node.addClass("FlowConnectorPath")
              .addClass(this.type)
              .attr("id", this.id)
              .attr("data-from", this._config.from.attr("id"))
              .attr("data-to", this._config.to.attr("id"))
              .data("instance", this);

    this._config.container.append(this.$node);
  }

  get path() {
    return this._path;
  }

  nudge(x, y) {
    // This function should allow the path to be nudged either vertically or horizontally
    // to avoid overlapping lines (as in, one that follow a same path). See the example
    // code below for what might happen but note, each individual path type will need to
    // have its own custom variant to cope with path requirements. The basic ForwardPath
    // is not likely to require anything so, for that and any other paths like it, this
    // function serves as a placeholder that does nothing, in the event it is called by
    // some accident or unintentional request.
    //
    // x & y params are multiples of how many nudges are required for each axis direction.
    // Nudge distance is controlled by hardcoded constant NUDGE_SPACING.
    // e.g. some_path_instance.nudge(2, 0) would cause a path to shift 2 x NUDGE_SPACING
    //      on the x axis but not to move on the y.

/*  TODO: ... kind of thing that needs to happen here, but dynamically.
    var $path = this.$node.find("path:first");
    console.log("$path: ", $path);
    console.log("type: ", this.type);
    console.log("d: ", $path.attr("d"));
    $path.attr("d", "M 4601.000244140625,62.5 v989.9999542236328 a10,10 0 0 0 10,10 h435 a10,10 0 0 1 10,10 v87.50004577636719 a10,10 0 0 1 -10,10 h-3260 a10,10 0 0 1 -10,-10 v-1087.5 a10,10 0 0 1 10,-10 h10");
    console.log("d: ", $path.attr("d"));
*/
  }
}


class ForwardPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      x: this.points.from_x,
      y: this.points.from_y + this.points.yDifference,
      width: this.points.xDifference
    }

    this._dimensions = { original: dimensions  } // Not expected to change.
    this.type = "ForwardPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var width = "h" + dimensions.width;
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(dimensions.x, dimensions.y), width));
  }


  // Since this arrow simple goes from point A to B, which is expected to
  // be between two adjacent items, it should not have any overlap issues
  // which would mean nudge() functionality is not a requirement.
}


class ForwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      vertical: this.points.yDifference - (CURVE_SPACING * 2),
      horizontal: this.points.via_x - CURVE_SPACING
    }

    this._dimensions = { original: dimensions }; // dimensions.current will be added in set path()
    this.type = "ForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var horizontal = "h" + dimensions.horizontal;
    var vertical = "v-" + dimensions.vertical;
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), horizontal, CURVE_RIGHT_UP, vertical, CURVE_UP_RIGHT));
  }

  nudge(x, y) {
    var dimensions = {
      horizontal: this._dimensions.current.horizontal - (x * NUDGE_SPACING),
      vertical: this._dimensions.current.vertical - (y * NUDGE_SPACING)
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class ForwardUpForwardDownPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: this.points.via_x - CURVE_SPACING,
      up: utilities.difference(this.points.from_y, this._config.top),
      forward2: this.points.xDifference - (this.points.via_x + (CURVE_SPACING * 4)),
      down: utilities.difference(this._config.top, this.points.to_y)
    }

    this._dimensions = { original: dimensions };
    this.type = "ForwardUpForwardDownPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var forward1 = "h" + dimensions.forward1;
    var up = "v-" + dimensions.up;
    var forward2 = "h" + dimensions.forward2;
    var down = "v" + dimensions.down;
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), forward1, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT, forward2, CURVE_RIGHT_DOWN, down, CURVE_DOWN_RIGHT));
  }

  nudge(x, y) {
    var dimensions = {
      forward1: this._dimensions.current.forward1 - (x * NUDGE_SPACING),
      up: this._dimensions.current.up + (y * NUDGE_SPACING),
      forward2: this._dimensions.current.forward2  + (x * NUDGE_SPACING),
      down: this._dimensions.current.down + (y * NUDGE_SPACING)
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class ForwardDownBackwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward: this.points.via_x - (CURVE_SPACING * 2),
      down: utilities.difference(this.points.from_y, this._config.bottom) - (CURVE_SPACING * 2),
      backward: utilities.difference(this.points.from_x + this.points.via_x, this.points.to_x),
      up: utilities.difference(this._config.bottom, this.points.from_y) + utilities.difference(this.points.from_y, this.points.to_y) - (CURVE_SPACING * 2)
    }

    this._dimensions = { original: dimensions };
    this.type = "ForwardDownBackwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var forward = "h" + dimensions.forward;
    var down = "v" + dimensions.down;
    var backward = "h-" + dimensions.backward;
    var up = "v-" + dimensions.up;

    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), forward, CURVE_RIGHT_DOWN, down, CURVE_DOWN_LEFT, backward, CURVE_LEFT_UP, up, CURVE_UP_RIGHT));
  }

  nudge(x, y) {
// TODO: MAYBE NEED TO RETHINK NUDGE TO ALLOW SINGLE LINE MOVEMENT, NOT
//       MOVING HORIZONTAL AND/OR VERTICAL AT SAME TIME (ASSUME ONLY
//       ONE OF THE TWO VERTICAL LINES CLASH AND NEEDS TO BE MOVED).
    var dimensions = {
      forward: this._dimensions.current.forward - (x * NUDGE_SPACING),
      down: this._dimensions.current.down + (y * NUDGE_SPACING),
      backward: this._dimensions.current.backward - (x * NUDGE_SPACING),
      up: this._dimensions.current.up + (y * NUDGE_SPACING)
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }

}


class DownForwardDownBackwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down1: utilities.difference(points.from_y, points.via_y) - CURVE_SPACING,
      forward: points.via_x - (CURVE_SPACING * 2),
      down2: utilities.difference(config.bottom, points.via_y) - CURVE_SPACING * 2,
      backward: points.via_x + utilities.difference(points.from_x, points.to_x) + 2, // +2 is a HACK to fix alignment due to arrow width and curve spacing not being taken out/added in.
      up: (utilities.difference(config.bottom, config.top) - points.to_y) - CURVE_SPACING * 2
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardDownBackwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var down1 = "v" + dimensions.down1;
    var forward = "h" + dimensions.forward;
    var down2 = "v" + dimensions.down2;
    var backward = "h-" + dimensions.backward;
    var up = "v-" + dimensions.up;
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down1, CURVE_DOWN_RIGHT, forward, CURVE_RIGHT_DOWN, down2, CURVE_DOWN_LEFT, backward, CURVE_LEFT_UP, up, CURVE_UP_RIGHT));
  }

  nudge(x, y) {
    var dimensions = {
      down1: this._dimensions.current.down1 + (y * NUDGE_SPACING),
      forward: this._dimensions.current.forward - (x * NUDGE_SPACING),
      down2: this._dimensions.current.down2 + (y * NUDGE_SPACING),
      backward: this._dimensions.current.backward - (x * NUDGE_SPACING),
      up: this._dimensions.current.up + (y * NUDGE_SPACING)
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class DownForwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down: utilities.difference(points.from_y, points.via_y) - CURVE_SPACING,
      forward1: points.via_x - (CURVE_SPACING * 2),
      up: utilities.difference(points.via_y, points.to_y) - (CURVE_SPACING * 2)
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var down = "v" + dimensions.down;
    var forward1 = "h" + dimensions.forward1;
    var up = "v-" + dimensions.up;
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down, CURVE_DOWN_RIGHT, forward1, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT));
  }

  nudge(x, y) {
    var dimensions = {
      down: this._dimensions.current.down,
      forward1: this._dimensions.current.forward1,
      up: this._dimensions.current.up
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class DownForwardUpForwardDownPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down1: utilities.difference(points.from_y, points.via_y) - CURVE_SPACING,
      forward1: points.via_x - (CURVE_SPACING * 2),
      up: utilities.difference(points.from_y, points.via_y) + utilities.difference(points.from_y, points.to_y) + utilities.difference(points.to_y, config.top),
      forward2: utilities.difference(points.from_x + points.via_x, points.to_x) - (CURVE_SPACING * 4),
      down2: points.to_y
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpForwardDown";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var down1 = "v" + dimensions.down1;
    var forward1 = "h" + dimensions.forward1;
    var up = "v-" + dimensions.up;
    var forward2 = "h" + dimensions.forward2;
    var down2 = "v" + dimensions.down2;
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down1, CURVE_DOWN_RIGHT, forward1, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT, forward2, CURVE_RIGHT_DOWN, down2, CURVE_DOWN_RIGHT));
  }

  nudge(x, y) {
    var dimensions = {
      down1: this._dimensions.current.down1,
      forward1: this._dimensions.current.forward1,
      up: this._dimensions.current.up,
      forward2: this._dimensions.current.forward2,
      down2: this._dimensions.current.down2
    }
    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class DownForwardPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down: points.yDifference - CURVE_SPACING,
      forward: points.xDifference
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var down = "v" + dimensions.down;
    var forward = "h" + dimensions.forward;
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down, CURVE_DOWN_RIGHT, forward));
  }

  nudge(x, y) {
    var dimensions = {
      down: "v" + this._dimensions.current.down,
      forward: "h" + this._dimensions.current.forward
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


function createSvg(paths) {
  const SVG_TAG_OPEN = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">";
  const SVG_TAG_CLOSE = "</svg>";
  var svg = SVG_TAG_OPEN + paths + SVG_TAG_CLOSE;
  return $(svg)
}


// Helper functions
function createArrowPath(points) {
  return "<path class=\"arrowPath\" d=\"M " + (points.to_x - 10) + "," + (points.to_y - 5) + " v10 l 10,-5 z\"></path>";
}

function createPath(d) {
  return "<path d=\"" + createPathDimensions(d) + "\"></path>"; // h10 is a little extra that should go under the arrow to make sure gaps are eliminated
}

function createPathDimensions(d) {
  return d + " h10"; // h10 is a little extra that should go under the arrow to make sure gaps are eliminated
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


// Make available for importing.
module.exports = {
  FlowConnectorPath: FlowConnectorPath,
  ForwardPath: ForwardPath,
  ForwardUpPath: ForwardUpPath,
  ForwardUpForwardDownPath: ForwardUpForwardDownPath,
  ForwardDownBackwardUpPath: ForwardDownBackwardUpPath,
  DownForwardDownBackwardUpPath: DownForwardDownBackwardUpPath,
  DownForwardUpPath: DownForwardUpPath,
  DownForwardUpForwardDownPath: DownForwardUpForwardDownPath,
  DownForwardPath: DownForwardPath
}
