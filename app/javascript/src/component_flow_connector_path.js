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

    // Public
    this.id = id;
    this.points = createConnectorPathPoints(utilities.mergeObjects({
                      via_x: 0, // If the connector needs to go via an certain route
                      via_y: 0  // you can add x/y coordinates to help route it.
                    }, points));

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

  avoidOverlap(coords) {
    // This function should be able to compare any passed coordinates with its own internal
    // positions that the makeup of its path occupies. If any path is found to occupy space
    // within the passed coordinate object, the function should return the name of which
    // path does.
// TODO adjust comment above...
    // If an overlap is found with the passed coordinates, the FlowConnectorPath nudge()
    // functionality is called to shift the line that matches (overlaps) with the passed
    // coordinates. The nudge() functionality is shifted by a factor of 1, e.g nudge(1, 0)
    //
    // This function isn't needed by all type of FlowConnectorPaths, so some will inherit
    // and use this empty function but, others will want to have a customised version that
    // works with their own path makeup.
    // e.g. something like this:
    // if(coordsOverlap(this.dimensions.coords.forward, coords)) {
    //   this.nudge(1, 0); // or whatever makes sense
    // }
    //
    // The general idea should be that the Overview object (or controller script) should
    // loop over found FlowConnectorPaths, and pass known used coordinates into each
    // in something like a `item.avoidOverlap({from[x,y], to:[x,y]});` form.
  }
}

function coordsOverlap(coords1, coords2) {
  // TODO: Incomplete idea - not sure what's happening here, just yet.
  //coords1 = { from: [0,0], to: [0,10] };
  //coords1 = { from: [0,5], to: [0,10] };
  return false;
}


class ForwardPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward: Math.round(this.points.xDifference)
    }

    this._dimensions = { original: dimensions  } // Not expected to change.
    this.type = "ForwardPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;
    var forward = new Line("forward", {
                    x: x,
                    y: y,
                    length: dimensions.forward,
                    prefix: "h"
                  });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ forward ];

    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   forward.path
                 );
  }

  // Since this arrow simply goes from point A to B, which is expected to
  // be between two adjacent items, it should not have any overlap issues
  // which would mean nudge() functionality is not a requirement.
}


class ForwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      up: Math.round(this.points.yDifference - (CURVE_SPACING * 2)),
      forward2: utilities.difference(Math.round((this.points.from_x + this.points.via_x) - CURVE_SPACING), this.points.to_x) // TODO: What about if it is not next column?
    }

    this._dimensions = { original: dimensions }; // dimensions.current will be added in set path()
    this.type = "ForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var forward1 = new Line("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (dimensions.forward1 + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new Line("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

   x += CURVE_SPACING;
   y -= CURVE_SPACING;
   var forward2 = new Line("forward2", {
                    x: x,
                    y: y,
                    length: dimensions.forward2,
                    prefix: "h"
                  });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ forward1, up, forward2 ];

    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   forward1.path,
                   CURVE_RIGHT_UP,
                   up.path,
                   CURVE_UP_RIGHT,
                   forward2.path
                 );
  }

  nudge(nF) {
    var dimensions = {
      forward1: this._dimensions.current.forward1 - (nF * NUDGE_SPACING),
      up: this._dimensions.current.up, // No movement should be required (and therefore possible) for this line.
      forward2: this._dimensions.current.forward2 + (nF * NUDGE_SPACING)
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }

  avoidOverlap(coords) {
    var name = ""; // A line name (see dimensions)
    return name;
  }
}


class ForwardUpForwardDownPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      up: Math.round(utilities.difference(this.points.from_y, this._config.top)),
      forward2: Math.round(this.points.xDifference - (this.points.via_x + (CURVE_SPACING * 4))),
      down: Math.round(utilities.difference(this._config.top, this.points.to_y))
    }

    this._dimensions = { original: dimensions };
    this.type = "ForwardUpForwardDownPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var forward1 = new Line("forward1", {
                 x: x,
                 y: y,
                 length: dimensions.forward1,
                 prefix: "h"
               });

    x += dimensions.foward1 + CURVE_SPACING;
    y -= CURVE_SPACING;
    var up = new Line("up", {
           x: x,
           y: y,
           length: dimensions.up,
           prefix: "v-"
         });

    x += CURVE_SPACING;
    y -= (dimensions.up + CURVE_SPACING);
    var forward2 = new Line("forward2", {
                 x: x,
                 y: y,
                 length: dimensions.forward2,
                 prefix: "h"
               });

    x += (dimensions.forward2 + CURVE_SPACING);
    y += CURVE_SPACING;
    var down = new Line("down", {
             x: x,
             y: y,
             length: dimensions.down,
             prefix: "v"
           });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ forward1, up, forward2, down ];

    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   forward1.path,
                   CURVE_RIGHT_UP,
                   up.path,
                   CURVE_UP_RIGHT,
                   forward2.path,
                   CURVE_RIGHT_DOWN,
                   down.path,
                   CURVE_DOWN_RIGHT
                 );
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
      forward1: Math.round(this.points.via_x - (CURVE_SPACING * 2)),
      down: Math.round(utilities.difference(this.points.from_y, this._config.bottom) - (CURVE_SPACING * 2)),
      backward: Math.round(utilities.difference(this.points.from_x + this.points.via_x, this.points.to_x) - CURVE_SPACING),
      up: Math.round(utilities.difference(this._config.bottom, this.points.from_y) + utilities.difference(this.points.from_y, this.points.to_y) - (CURVE_SPACING * 2)),
      forward2: 0
    }

    this._dimensions = { original: dimensions };
    this.type = "ForwardDownBackwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var forward1 = new Line("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (dimensions.foward1 + CURVE_SPACING);
    y += CURVE_SPACING;
    var down = new Line("down", {
                 x: x,
                 y: y,
                 length: dimensions.down,
                 prefix: "v"
               });

    x -= CURVE_SPACING;
    y += CURVE_SPACING;
    var backward = new Line("backward", {
                     x: x,
                     y: y,
                     length: dimensions.backward,
                     prefix: "h-"
                   });

    x -= (dimensions.backward + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new Line("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= CURVE_SPACING;
    var forward2 = new Line("up", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    this._dimensions.current = dimensions;
    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   forward1.path,
                   CURVE_RIGHT_DOWN,
                   down.path,
                   CURVE_DOWN_LEFT,
                   backward.path,
                   CURVE_LEFT_UP,
                   up.path,
                   CURVE_UP_RIGHT,
                   forward2.path);
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
      down1: utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING,
      forward1: this.points.via_x - (CURVE_SPACING * 2),
      down2: utilities.difference(config.bottom, this.points.via_y) - CURVE_SPACING * 2,
      backward: this.points.via_x + utilities.difference(this.points.from_x, this.points.to_x),
      up: (utilities.difference(config.bottom, config.top) - this.points.to_y) - CURVE_SPACING * 2,
      forward2: 0
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardDownBackwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x + CURVE_SPACING;
    var y = this.points.from_y + CURVE_SPACING;

    var down1 = new Line("forward1", {
                  x: x,
                  y: y,
                  length: dimensions.down1,
                  prefix: "v"
                });

    x += CURVE_SPACING;
    y += (down1 + CURVE_SPACING);
    var forward1 = new Line("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += CURVE_SPACING;
    y += CURVE_SPACING;
    var down2 = new Line("down2", {
                  x: x,
                  y: y,
                  length: dimensions.down2,
                  prefix: "v"
                });

    x -= CURVE_SPACING;
    y += (dimensions.down2 + CURVE_SPACING);
    var backward = new Line("backward", {
                     x: x,
                     y: y,
                     length: dimensions.backward,
                     prefix: "h-"
                   });

    x -= (CURVE_SPACING + dimensions.backward);
    y -= CURVE_SPACING;
    var up = new Line("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= (up + CURVE_SPACING);
    var forward2 = new Line("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    this._dimensions.current = dimensions;
    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   down1.path,
                   CURVE_DOWN_RIGHT,
                   forward1.path,
                   CURVE_RIGHT_DOWN,
                   down2.path,
                   CURVE_DOWN_LEFT,
                   backward.path,
                   CURVE_LEFT_UP,
                   up.path,
                   CURVE_UP_RIGHT,
                   forward2.path
                 );
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
      down: Math.round(utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING),
      forward1: Math.round(points.via_x - (CURVE_SPACING * 2)),
      up: Math.round(utilities.difference(points.via_y, this.points.to_y) - (CURVE_SPACING * 2)),
      forward2: 0
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down = new Line("down", {
                 x: x,
                 y: y,
                 length: dimensions.down,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += (down + CURVE_SPACING);
    var forward1 = new Line("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1 + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new Line("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= (up + CURVE_SPACING);
    var forward2 = new Line("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "v-"
                   });

    this._dimensions.current = dimensions;
    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   down.path,
                   CURVE_DOWN_RIGHT,
                   forward1.path,
                   CURVE_RIGHT_UP,
                   up.path,
                   CURVE_UP_RIGHT,
                   forward2.path
                 );
  }

  nudge(nF) {
    var dimensions = {
      down: this._dimensions.current.down,
      forward1: this._dimensions.current.forward1 - (nF * NUDGE_SPACING),
      up: this._dimensions.current.up,
      forward2: this._dimensions.current.forward2 + (nF * NUDGE_SPACING),
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class DownForwardUpForwardDownPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down1: Math.round(utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING),
      forward1: Math.round(points.via_x - (CURVE_SPACING * 2)),
      up: Math.round(utilities.difference(points.from_y, this.points.via_y) + utilities.difference(points.from_y, this.points.to_y) + utilities.difference(points.to_y, config.top)),
      forward2: Math.round(utilities.difference(points.from_x + this.points.via_x, this.points.to_x) - (CURVE_SPACING * 4)),
      down2: Math.round(points.to_y)
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpForwardDown";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down1 = new Line("down1", {
                 x: x,
                 y: y,
                 length: dimensions.down1,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += CURVE_SPACING;
    var forward1 = new Line("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1 + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new Line("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= (up + CURVE_SPACING);
    var forward2 = new Line("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    x += (forward2 + CURVE_SPACING);
    y += CURVE_SPACING;
    var down2 = new Line("down2", {
                  x: x,
                  y: y,
                  length: dimensions.down2,
                  prefix: "v"
                });

    this._dimensions.current = dimensions;
    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   down1.path,
                   CURVE_DOWN_RIGHT,
                   forward1.path,
                   CURVE_RIGHT_UP,
                   up.path,
                   CURVE_UP_RIGHT,
                   forward2.path,
                   CURVE_RIGHT_DOWN,
                   down2.path,
                   CURVE_DOWN_RIGHT
                 );
  }

  nudge(nF, nU) {
    var dimensions = {
      down1: this._dimensions.current.down1,
      forward1: this._dimensions.current.forward1 - (nF * NUDGE_SPACING),
      up: this._dimensions.current.up + (nU * NUDGE_SPACING),
      forward2: this._dimensions.current.forward2 + (nF * NUDGE_SPACING),
      down2: this._dimensions.current.down2 + (nU * NUDGE_SPACING)
    }
    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class DownForwardDownForwardPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down1: Math.round(utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING),
      forward1: Math.round(points.via_x - (CURVE_SPACING * 2)),
      down2: Math.round(utilities.difference(points.via_y, this.points.to_y) - (CURVE_SPACING * 2)),
      forward2: Math.round(utilities.difference(points.from_x + this.points.via_x, this.points.to_x) - (CURVE_SPACING * 2))
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpForwardDown";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down1 = new Line("down1", {
                 x: x,
                 y: y,
                 length: dimensions.down1,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += CURVE_SPACING;
    var forward1 = new Line("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1 + CURVE_SPACING);
    y += CURVE_SPACING;
    var down2 = new Line("down2", {
                  x: x,
                  y: y,
                  length: dimensions.down2,
                  prefix: "v"
                });

    x += CURVE_SPACING;
    y += (down2 + CURVE_SPACING);
    var forward2 = new Line("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    this._dimensions.current = dimensions;
    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   down1.path,
                   CURVE_DOWN_RIGHT,
                   forward1.path,
                   CURVE_RIGHT_DOWN,
                   down2.path,
                   CURVE_DOWN_RIGHT,
                   forward2.path
                 );
  }

  nudge(nF) {
    var dimensions = {
      down1: this._dimensions.current.down1,
      forward1: this._dimensions.current.forward1 - (nF * NUDGE_SPACING),
      down2: this._dimensions.current.down2,
      forward2: this._dimensions.current.forward2 + (nF * NUDGE_SPACING)
    }
    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class DownForwardPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down: Math.round(this.points.yDifference - CURVE_SPACING),
      forward: Math.round(this.points.xDifference)
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down = new Line("down", {
                 x: x,
                 y: y,
                 length: dimensions.down,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += (down + CURVE_SPACING);
    var forward = new Line("forward", {
           x: x,
           y: y,
           length: dimensions.forward,
           prefix: "h"
         });

    this._dimensions.current = dimensions;
    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   down.path,
                   CURVE_DOWN_RIGHT,
                   forward.path
                 );
  }

  // Since this arrow simply goes from Branch, via Condition A to point B, which is expected
  // to be the next adjacent item, it should not have any overlap issues which would mean
  // nudge() functionality is also not a requirement.
}


class Line {

  // @name   (String) You want this to correspond to the internal dimension name (e.g. 'forward' or 'down')
  // @config (Object) Should be populated with {
  //                    start: 0, // An x or y number depending on type.
  //                    end: 10,  // An x or y number depending on type.
  //                    type: [horizontal|vertical] // String value
  //                  }
  constructor(name, config) {
    this._private = {
      x: config.x,
      y: config.y,
      length: config.length,
      name: name,
      prefix: config.prefix,
      type: config.type
    }

    this.range = [config.x, config.y];
  }

  get name() {
    return this._private.name;
  }

  get type() {
    return this._private.type;
  }

  // Returns a string used for part of an svg <path> d attribute value.
  get path() {
    return this._private.prefix + this._private.length
  }

  get range() {
    return this._private.range;
  }

  set range(points /* [x, y] */) {
    var r = [];
    var begin = (this._private.type == "horizontal") ? [0] : [1];
    var end = this._private.length;
    if(begin > end) {
      for(var i=begin; i > end; --i) {
        r.push(i);
      }
    }
    else {
      for(var i=begin; i < end; ++i) {
        r.push(i);
      }
    }

    this._private.range = r;
  }
}



/*************************************
 * HELPER FUNCTIONS
 *************************************/

function createConnectorPathPoints(points) {
  for(var point in points) {
    if(points.hasOwnProperty(point)) {
      points[point] = Math.round(points[point]);
    }
  }

  points.xDifference = Math.round(utilities.difference(points.from_x, points.to_x));
  points.yDifference = Math.round(utilities.difference(points.from_y, points.to_y));
  return points;
}

function createSvg(paths) {
  const SVG_TAG_OPEN = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">";
  const SVG_TAG_CLOSE = "</svg>";
  var svg = SVG_TAG_OPEN + paths + SVG_TAG_CLOSE;
  return $(svg)
}

function createArrowPath(points) {
  return "<path class=\"arrowPath\" d=\"M " + (points.to_x - 11) + "," + (points.to_y - 5) + " v10 l 10,-5 z\"></path>";
}

function createPath(d) {
  return "<path d=\"" + d + "\"></path>"; // h10 is a little extra that should go under the arrow to make sure gaps are eliminated
}

function pathD(/* unlimited */) {
  var path = "M";
  for(var i=0; i<arguments.length; ++i) {
    path += (" " + arguments[i]);
  }
  return path;
}

function xy(x, y) {
  return String(Math.round(x)) + "," + String(Math.round(y));
}



/*************************************
 * Make available for importing.
 *************************************/

module.exports = {
  FlowConnectorPath: FlowConnectorPath,
  ForwardPath: ForwardPath,
  ForwardUpPath: ForwardUpPath,
  ForwardUpForwardDownPath: ForwardUpForwardDownPath,
  ForwardDownBackwardUpPath: ForwardDownBackwardUpPath,
  DownForwardDownBackwardUpPath: DownForwardDownBackwardUpPath,
  DownForwardUpPath: DownForwardUpPath,
  DownForwardUpForwardDownPath: DownForwardUpForwardDownPath,
  DownForwardDownForwardPath: DownForwardDownForwardPath,
  DownForwardPath: DownForwardPath
}
