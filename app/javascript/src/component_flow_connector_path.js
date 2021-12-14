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

  nudge(nX, nY, nZ) {
    // This function should allow the path lines to be nudged either vertically or horizontally
    // to avoid overlapping (as in, one that follows the same path as another). The basic
    // ForwardPath is not likely to require any nudge movement because it is expected to follow
    // a simple, and individual, point A to point B path. However, for many other paths this can
    // be used to move individual, or multiple, lines within the same path. To do this, simply
    // pass a multiple (1, 2, 3, etc) as a param to affect each (or any coded) lines within the
    // affected path.
    // e.g. If you have a path made of of down + forward + up lines, you may want to create a
    //      nudge function that accepts params nD, nF, and nU to allow inner working of the
    //      function to multiply the calculations by the standard NUDGE_SPACING amount.
    //      Something along the lines of:
    //             var down = (nD * NUDGE_SPACING);
    //             var foward = (nF * NUDGE_SPACING);
    //             var up = (nU * NUDGE_SPACING);
    //
    // For more examples, see the actual nudge() functions already in place or (at time of
    // writing) the following code that is used for the simplistic ForwardUpPath class.
    //
    //   nudge(nH, nV) {
    //     var dimensions = {
    //       horizontal: this._dimensions.current.horizontal - (nH * NUDGE_SPACING),
    //       vertical: this._dimensions.current.vertical - (nV * NUDGE_SPACING)
    //     }
    //
    //     this.path = dimensions;
    //     this.$node.find("path:first").attr("d", this._path);
    //   }
    //
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
    var width = "h" + Math.ceil(dimensions.width);
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(dimensions.x, dimensions.y), width));
  }


  // Since this arrow simply goes from point A to B, which is expected to
  // be between two adjacent items, it should not have any overlap issues
  // which would mean nudge() functionality is not a requirement.
}


class ForwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      horizontal1: this.points.via_x - CURVE_SPACING,
      horizontal2: 0,
      vertical: this.points.yDifference - (CURVE_SPACING * 2)
    }

    this._dimensions = { original: dimensions }; // dimensions.current will be added in set path()
    this.type = "ForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var horizontal1 = "h" + Math.ceil(dimensions.horizontal1);
    var horizontal2 = "h" + Math.ceil(dimensions.horizontal2);
    var vertical = "v-" + Math.ceil(dimensions.vertical);

    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), horizontal1, CURVE_RIGHT_UP, vertical, CURVE_UP_RIGHT, horizontal2));
  }

  nudge(nH) {
    var dimensions = {
      horizontal1: this._dimensions.current.horizontal1 - (nH * NUDGE_SPACING),
      horizontal2: this._dimensions.current.horizontal2 + (nH * NUDGE_SPACING),
      vertical: this._dimensions.current.vertical // No movement should be required (and therefore possible) for this line.
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
    var forward1 = "h" + Math.ceil(dimensions.forward1);
    var up = "v-" + Math.ceil(dimensions.up);
    var forward2 = "h" + Math.ceil(dimensions.forward2);
    var down = "v" + Math.ceil(dimensions.down);
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), forward1, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT, forward2, CURVE_RIGHT_DOWN, down, CURVE_DOWN_RIGHT));
  }

  nudge(nF, nU) {
    var dimensions = {
      forward1: this._dimensions.current.forward1 - (nF * NUDGE_SPACING),
      up: this._dimensions.current.up + (nU * NUDGE_SPACING),
      forward2: this._dimensions.current.forward2 + (nF * NUDGE_SPACING),
      down: this._dimensions.current.down + (nU * NUDGE_SPACING)
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class ForwardDownBackwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: this.points.via_x - (CURVE_SPACING * 2),
      down: utilities.difference(this.points.from_y, this._config.bottom) - (CURVE_SPACING * 2),
      backward: utilities.difference(this.points.from_x + this.points.via_x, this.points.to_x),
      up: utilities.difference(this._config.bottom, this.points.from_y) + utilities.difference(this.points.from_y, this.points.to_y) - (CURVE_SPACING * 2),
      forward2: 0
    }

    this._dimensions = { original: dimensions };
    this.type = "ForwardDownBackwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var forward1 = "h" + Math.ceil(dimensions.forward1);
    var down = "v" + Math.ceil(dimensions.down);
    var backward = "h-" + Math.ceil(dimensions.backward);
    var up = "v-" + Math.ceil(dimensions.up);
    var forward2 = "h" + Math.ceil(dimensions.forward2);

    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), forward1, CURVE_RIGHT_DOWN, down, CURVE_DOWN_LEFT, backward, CURVE_LEFT_UP, up, CURVE_UP_RIGHT, forward2));
  }

  nudge(nF, nD, nB) {
    var dimensions = {
      forward1: this._dimensions.current.forward1 - (nF * NUDGE_SPACING),
      down: this._dimensions.current.down + (nD * NUDGE_SPACING),
      backward: this._dimensions.current.backward - (nF * NUDGE_SPACING) + (nB * NUDGE_SPACING),
      up: this._dimensions.current.up + (nD * NUDGE_SPACING),
      forward2: this._dimensions.current.forward2 + (nB * NUDGE_SPACING)
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
      forward1: points.via_x - (CURVE_SPACING * 2),
      down2: utilities.difference(config.bottom, points.via_y) - CURVE_SPACING * 2,
      backward: points.via_x + utilities.difference(points.from_x, points.to_x) + 2, // +2 is a HACK to fix alignment due to arrow width and curve spacing not being taken out/added in.
      up: (utilities.difference(config.bottom, config.top) - points.to_y) - CURVE_SPACING * 2,
      forward2: 0
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardDownBackwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var down1 = "v" + Math.ceil(dimensions.down1);
    var forward1 = "h" + Math.ceil(dimensions.forward1);
    var down2 = "v" + Math.ceil(dimensions.down2);
    var backward = "h-" + Math.ceil(dimensions.backward);
    var up = "v-" + Math.ceil(dimensions.up);
    var forward2 = "h" + Math.ceil(dimensions.forward2);
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down1, CURVE_DOWN_RIGHT, forward1, CURVE_RIGHT_DOWN, down2, CURVE_DOWN_LEFT, backward, CURVE_LEFT_UP, up, CURVE_UP_RIGHT, forward2));
  }

  nudge(nD, nB) {
    var dimensions = {
      down1: this._dimensions.current.down1,
      forward1: this._dimensions.current.forward1,
      down2: this._dimensions.current.down2 + (nD * NUDGE_SPACING),
      backward: this._dimensions.current.backward + (nB * NUDGE_SPACING),
      up: this._dimensions.current.up + (nD * NUDGE_SPACING),
      forward2:  this._dimensions.current.forward2 + (nB * NUDGE_SPACING)
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
      forward: points.via_x - (CURVE_SPACING * 2),
      up: utilities.difference(points.via_y, points.to_y) - (CURVE_SPACING * 2)
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var down = "v" + Math.ceil(dimensions.down);
    var forward = "h" + Math.ceil(dimensions.forward);
    var up = "v-" + Math.ceil(dimensions.up);
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down, CURVE_DOWN_RIGHT, forward, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT));
  }

  nudge(nD, nF, nU) {
    var dimensions = {
      down: this._dimensions.current.down + (nD * NUDGE_SPACING),
      forward: this._dimensions.current.forward + (nF * NUDGE_SPACING),
      up: this._dimensions.current.up - (nU * NUDGE_SPACING)
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
    var down1 = "v" + Math.ceil(dimensions.down1);
    var forward1 = "h" + Math.ceil(dimensions.forward1);
    var up = "v-" + Math.ceil(dimensions.up);
    var forward2 = "h" + Math.ceil(dimensions.forward2);
    var down2 = "v" + Math.ceil(dimensions.down2);
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down1, CURVE_DOWN_RIGHT, forward1, CURVE_RIGHT_UP, up, CURVE_UP_RIGHT, forward2, CURVE_RIGHT_DOWN, down2, CURVE_DOWN_RIGHT));
  }

  nudge(nD1, nF1, nU, nF2, nD2) {
    var dimensions = {
      down1: this._dimensions.current.down1 + (nD1 * NUDGE_SPACING),
      forward1: this._dimensions.current.forward1 + (nF1 * NUDGE_SPACING),
      up: this._dimensions.current.up + (nU * NUDGE_SPACING),
      forward2: this._dimensions.current.forward2 + (nF2 * NUDGE_SPACING),
      down2: this._dimensions.current.down2 + (nD2 * NUDGE_SPACING)
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
    var down = "v" + Math.ceil(dimensions.down);
    var forward = "h" + Math.ceil(dimensions.forward);
    this._dimensions.current = dimensions;
    this._path = createPathDimensions(pathD(xy(this.points.from_x, this.points.from_y), down, CURVE_DOWN_RIGHT, forward));
  }

  nudge(nD, nF) {
    var dimensions = {
      down: "v" + this._dimensions.current.down + (nD * NUDGE_SPACING),
      forward: "h" + this._dimensions.current.forward + (nF * NUDGE_SPACING)
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
  return String(Math.ceil(x)) + "," + String(Math.ceil(y));
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
