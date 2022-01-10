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
const NUDGE_SPACING = 10;
const CURVE_RIGHT_UP = "a10,10 0 0 0 10,-10";
const CURVE_UP_RIGHT = "a10,10 0 0 1 10,-10";
const CURVE_RIGHT_DOWN = "a10,10 0 0 1 10,10";
const CURVE_DOWN_LEFT = "a10,10 0 0 1 -10,10";
const CURVE_DOWN_RIGHT = "a10,10 0 0 0 10,10";
const CURVE_LEFT_UP = "a10,10 0 0 1 -10,-10";
const HORIZONTAL = "horizontal";
const VERTICAL = "vertical";
const PATH_OVERLAP_MINIMUM = 10; // Minimum amount of overlapping contact point to trigger an overlap situation.
const LINE_PIXEL_TOLERANCE = 4; // Arbitrary number just for some pixel tolerance


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

  get path() {
    return this._path;
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

    // Uncomment for developer helper code only
    //this.makeLinesVisibleForTesting();
  }

  // Return all FlowConnectorLines or just those matching the passed type.
  lines(type="") {
    var lineArr = this._dimensions.lines;
    var filtered = [];

    for(var i=0; i<lineArr.length; ++i) {
      if(lineArr[i].type == type) {
        filtered.push(lineArr[i]);
      }
    }
    return type != "" ? filtered : lineArr;
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

  makeLinesVisibleForTesting() {
    // DEVELOPMENT ONLY FUNCTION
    // When debugging problems with creates Lines (used in comparison for overlapping FlowConnectorPaths),
    // this funciton can be called to make things visible and, therefore, a bit easier. See this.build().
    for(var i=0; i<this._dimensions.lines.length; ++i) {
      this._config.container.append(this._dimensions.lines[i].testOnlySvg());
    }
  }

  avoidOverlap(path) {
    // TODO: WIP currently only concerned with vertical lines.
    //       This will develop and evolve as solutions are found.
    // If an overlap is found with the Lines of the passed path, the FlowConnectorPath.nudge()
    // functionality of the passed path is called to shift the line that matches (overlaps).
    // The minimum amount of overlap is controlled by PATH_OVERLAP_MINIMUM.
    //
    // The general idea should be that an Overview object (or controller script) should
    // loop over found FlowConnectorPaths passing each one, in turn, into this function
    // for overlap comparison.
    //
    // Note: This function will return true/false depending on whether it found and fixed any
    //       overlap.
    var vLines = this.lines("vertical");
    var hLines = this.lines("horizontal");
    var vComparisonLines = path.lines("vertical");
    var hComparisonLines = path.lines("horizontal");
    var overlapCount = 0;
    var fixedOverlap = false;

    // Loop over each line in current FlowConnectorPath
    for(var v=0; v < vLines.length; ++v) {
      let vr = vLines[v].range;

      // Compare with each line in the passed FlowConnectorPath
      for(var c=0; c < vComparisonLines.length; ++c) {
        let cr = vComparisonLines[c].range;
        let vLineX = vLines[v].prop("x");
        let vComparisonLineX = vComparisonLines[c].prop("x");
        let overlapCount = 0;

console.log("test (%s.%s vs. %s.%s): ", this.type, vLines[v].name, path.type, vComparisonLines[c].name, (vComparisonLineX >= (vLineX - 2) && vComparisonLineX <= (vLineX + 2)));

        // For vertical lines, we need to first check if they occupy the same horizontal point/position.
        if(vComparisonLineX >= (vLineX - LINE_PIXEL_TOLERANCE) && vComparisonLineX <= (vLineX + LINE_PIXEL_TOLERANCE)) {

          // Check each point in the comparison line range to find matches in the current line range.
          for(var i=0; i < cr.length; ++i) {
            if(vr.indexOf(cr[i]) >= 0) {
              overlapCount++;
            }
          }

          // If there were enough overlaps (matched points in each) then we need to nudge a line.
          if(overlapCount >= PATH_OVERLAP_MINIMUM) {
            let error = "Overlap found between '" + this.type + "." + vLines[v].name + "' and '" + path.type + "." + vComparisonLines[c].name + "'";
            //console.error("Overlap found between '%s.%s' and '%s.%s'", this.type, vLines[v].name, path.type, vComparisonLines[c].name);
            console.error(error);
            console.warn("TYPE: ", path.type);
            console.warn("Line: ", path.$node.find("path").eq(0));
            path.nudge(vComparisonLines[c].name);
            fixedOverlap = true;
          }
        }
      }
    }

    console.groupEnd();
    return fixedOverlap;
  }
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
    var forward = new FlowConnectorLine("forward", {
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
      forward2: Math.round(utilities.difference((this.points.from_x + this.points.via_x) - CURVE_SPACING, this.points.to_x))
    }

    this._dimensions = { original: dimensions }; // dimensions.current will be added in set path()
    this.type = "ForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var forward1 = new FlowConnectorLine("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1.prop("length") + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new FlowConnectorLine("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

   x += CURVE_SPACING;
   y -= (up.prop("length") + CURVE_SPACING);
   var forward2 = new FlowConnectorLine("forward2", {
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

  nudge(linename) {
    var d = this._dimensions.current;
    switch(linename) {
      case "forward":
           console.log("DEV HELPER MESSAGE: This can be ignored");
           // There should be no clash on this line by leaving this line and comment for code clarity.
           break;

      case "up":
console.log("fixed");
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           break;
    }

    this.path = d;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class ForwardUpForwardDownPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      up: Math.round(utilities.difference(this.points.from_y, this._config.top)),
      forward2: Math.round(this.points.xDifference - (this.points.via_x + (CURVE_SPACING * 4))),
      down: Math.round(utilities.difference(this._config.top, this.points.to_y)),
      forward3: 0 // Expected start value
    }

    this._dimensions = { original: dimensions };
    this.type = "ForwardUpForwardDownPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;
    var forward1 = new FlowConnectorLine("forward1", {
                 x: x,
                 y: y,
                 length: dimensions.forward1,
                 prefix: "h"
               });

    x += forward1.prop("length") + CURVE_SPACING;
    y -= CURVE_SPACING;
    var up = new FlowConnectorLine("up", {
           x: x,
           y: y,
           length: dimensions.up,
           prefix: "v-"
         });

    x += CURVE_SPACING;
    y -= (up.prop("length") + CURVE_SPACING);
    var forward2 = new FlowConnectorLine("forward2", {
                 x: x,
                 y: y,
                 length: dimensions.forward2,
                 prefix: "h"
               });

    x += (forward2.prop("length") + CURVE_SPACING);
    y += CURVE_SPACING;
    var down = new FlowConnectorLine("down", {
             x: x,
             y: y,
             length: dimensions.down,
             prefix: "v"
           });

    x += CURVE_SPACING;
    y += (down.prop("length") + CURVE_SPACING);
    var forward3 = new FlowConnectorLine("forward3", {
             x: x,
             y: y,
             length: dimensions.forward3,
             prefix: "h"
           });


    this._dimensions.current = dimensions;
    this._dimensions.lines = [ forward1, up, forward2, down, forward3 ];

    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   forward1.path,
                   CURVE_RIGHT_UP,
                   up.path,
                   CURVE_UP_RIGHT,
                   forward2.path,
                   CURVE_RIGHT_DOWN,
                   down.path,
                   CURVE_DOWN_RIGHT,
                   forward3.path,
                 );
  }
/*
  nudge(nF, nU) {
console.warn("TODO... TODO... TODO... TODO... TODO... TODO... TODO... TODO... TODO... TODO... TODO... ");
return;
    var dimensions = {
      forward1: this._dimensions.current.forward1 - (nF * NUDGE_SPACING),
      up: this._dimensions.current.up + (nU * NUDGE_SPACING),
      forward2: this._dimensions.current.forward2 + (nF * NUDGE_SPACING),
      down: this._dimensions.current.down + (nU * NUDGE_SPACING)
    }

    this.path = dimensions;
    this.$node.find("path:first").attr("d", this._path);
  }
*/
  nudge(linename) {
    var d = this._dimensions.current;
    switch(linename) {
      case "up":
console.log("fixed");
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           break;
      case "down":
console.log("fixed");
           d.forward2 -= NUDGE_SPACING;
           d.forward3 += NUDGE_SPACING;
    }

    this.path = d;
    this.$node.find("path:first").attr("d", this._path);
  }
}


class ForwardDownBackwardUpPath extends FlowConnectorPath {
  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      down: Math.round(utilities.difference(this.points.from_y, this._config.bottom) - (CURVE_SPACING * 2)),
      backward: Math.round(utilities.difference(this.points.from_x + this.points.via_x, this.points.to_x)),
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

    var forward1 = new FlowConnectorLine("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1.prop("length") + CURVE_SPACING);
    y += CURVE_SPACING;
    var down = new FlowConnectorLine("down", {
                 x: x,
                 y: y,
                 length: dimensions.down,
                 prefix: "v"
               });

    x -= CURVE_SPACING;
    y += (down.prop("length") + CURVE_SPACING);
    var backward = new FlowConnectorLine("backward", {
                     x: x,
                     y: y,
                     length: dimensions.backward,
                     prefix: "h-"
                   });

    x -= (backward.prop("length") + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new FlowConnectorLine("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= (up.prop("length") + CURVE_SPACING);
    var forward2 = new FlowConnectorLine("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ forward1, down, backward, up, forward2 ];

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
return;
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
      down1: Math.round(utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING),
      forward1: Math.round(this.points.via_x - (CURVE_SPACING * 2)),
      down2: Math.round(utilities.difference(config.bottom, this.points.via_y) - CURVE_SPACING * 2),
      backward: Math.round(this.points.via_x + utilities.difference(this.points.from_x, this.points.to_x)),
      up: Math.round((utilities.difference(config.bottom, config.top) - this.points.to_y) - CURVE_SPACING * 2),
      forward2: 0 // TODO: This doesn't look right. What should it be?
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardDownBackwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down1 = new FlowConnectorLine("down1", {
                  x: x,
                  y: y,
                  length: dimensions.down1,
                  prefix: "v"
                });

    x += CURVE_SPACING;
    y += (down1.prop("length") + CURVE_SPACING);
    var forward1 = new FlowConnectorLine("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1.prop("length") + CURVE_SPACING);
    y += CURVE_SPACING;
    var down2 = new FlowConnectorLine("down2", {
                  x: x,
                  y: y,
                  length: dimensions.down2,
                  prefix: "v"
                });

    x -= CURVE_SPACING;
    y += (down2.prop("length") + CURVE_SPACING);
    var backward = new FlowConnectorLine("backward", {
                     x: x,
                     y: y,
                     length: dimensions.backward,
                     prefix: "h-"
                   });

    x -= (CURVE_SPACING + dimensions.backward);
    y -= CURVE_SPACING;
    var up = new FlowConnectorLine("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= (up.prop("length") + CURVE_SPACING);
    var forward2 = new FlowConnectorLine("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ down1, forward1, down2, backward, up, forward2 ];

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

/*
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
*/
  nudge(linename) {
    var d = this._dimensions.current;
    switch(linename) {
      case "down1":
           console.log("DEV HELPER MESSAGE: This can be ignored");
           // There should be no clash on this line by leaving this line and comment for code clarity.
           break;

      case "down2":
console.log("fixed");
           d.forward1 -= NUDGE_SPACING;
           d.backward -= NUDGE_SPACING;
           break;

      case "up":
console.log("fixed");
           d.forward += NUDGE_SPACING;
           d.backward -= NUDGE_SPACING;
           break;
    }

    this.path = d;
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
      forward2: Math.round(utilities.difference(points.from_x, points.to_x) - (points.via_x + CURVE_SPACING))
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down = new FlowConnectorLine("down", {
                 x: x,
                 y: y,
                 length: dimensions.down,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += (down.prop("length") + CURVE_SPACING);
    var forward1 = new FlowConnectorLine("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1.prop("length") + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new FlowConnectorLine("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= (up.prop("length") + CURVE_SPACING);
    var forward2 = new FlowConnectorLine("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ down, forward1, up, forward2 ];

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

  nudge(linename) {
    var d = this._dimensions.current;
    switch(linename) {
      case "down":
      case "forward1":
           console.log("DEV HELPER MESSAGE: This can be ignored");
           // There should be no clash on this line by leaving this line and comment for code clarity.
           break;

      case "up":
console.log("fixed");
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           break;

      case "forward2":
           // This possibly does not need clash functionality as it is here to support the shifting
           // of the 'up' line only (see workings above to understand).
           break;
    }

    this.path = d;
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
      down2: Math.round(points.to_y),
      forward3: 0 // start value
    }

    this._dimensions = { original: dimensions };
    this.type = "DownForwardUpForwardDownPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down1 = new FlowConnectorLine("down1", {
                 x: x,
                 y: y,
                 length: dimensions.down1,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += (down1.prop("length") + CURVE_SPACING);
    var forward1 = new FlowConnectorLine("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1.prop("length") + CURVE_SPACING);
    y -= CURVE_SPACING;
    var up = new FlowConnectorLine("up", {
               x: x,
               y: y,
               length: dimensions.up,
               prefix: "v-"
             });

    x += CURVE_SPACING;
    y -= (up.prop("length") + CURVE_SPACING);
    var forward2 = new FlowConnectorLine("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    x += (forward2.prop("length") + CURVE_SPACING);
    y += CURVE_SPACING;
    var down2 = new FlowConnectorLine("down2", {
                  x: x,
                  y: y,
                  length: dimensions.down2,
                  prefix: "v"
                });

    x += CURVE_SPACING;
    y += down2.prop("length") + CURVE_SPACING;
    var forward3 = new FlowConnectorLine("forward3", {
                  x: x,
                  y: y,
                  length: dimensions.forward3,
                  prefix: "h"
                });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ down1, forward1, up, forward2, down2, forward3 ];

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
                   CURVE_DOWN_RIGHT,
                   forward3.path
                 );
  }

/*
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
*/
  nudge(linename) {
    var d = this._dimensions.current;
    switch(linename) {
      case "down1":
           console.log("DEV HELPER MESSAGE: This can be ignored");
           // There should be no clash on this line by leaving this line and comment for code clarity.
           break;

      case "up":
console.log("fixed");
           d.forward1 -= NUDGE_SPACING;
           d.forward2 -= NUDGE_SPACING;
           break;

      case "down2":
console.log("fixed");
           d.forward2 -= NUDGE_SPACING;
           d.forward3 += NUDGE_SPACING;
           break;
    }
    this.path = d;
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
    this.type = "DownForwardDownForwardPath";
    this.path = dimensions;
    this.build();
  }

  set path(dimensions) {
    var x = this.points.from_x;
    var y = this.points.from_y;

    var down1 = new FlowConnectorLine("down1", {
                 x: x,
                 y: y,
                 length: dimensions.down1,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += (down1.prop("length") + CURVE_SPACING);
    var forward1 = new FlowConnectorLine("forward1", {
                     x: x,
                     y: y,
                     length: dimensions.forward1,
                     prefix: "h"
                   });

    x += (forward1.prop("length") + CURVE_SPACING);
    y += CURVE_SPACING;
    var down2 = new FlowConnectorLine("down2", {
                  x: x,
                  y: y,
                  length: dimensions.down2,
                  prefix: "v"
                });

    x += CURVE_SPACING;
    y += (down2.prop("length") + CURVE_SPACING);
    var forward2 = new FlowConnectorLine("forward2", {
                     x: x,
                     y: y,
                     length: dimensions.forward2,
                     prefix: "h"
                   });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ down1, forward1, down2, forward2 ];

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

/*
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
*/
  nudge(linename) {
    var d = this._dimensions.current;
    switch(linename) {
      case "down1":
           console.log("DEV HELPER MESSAGE: This can be ignored");
           // There should be no clash on this line by leaving this line and comment for code clarity.
           break;

      case "down2":
console.log("fixed");
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           break;
    }
    this.path = d;
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

    var down = new FlowConnectorLine("down", {
                 x: x,
                 y: y,
                 length: dimensions.down,
                 prefix: "v"
               });

    x += CURVE_SPACING;
    y += (down.prop("length") + CURVE_SPACING);
    var forward = new FlowConnectorLine("forward", {
           x: x,
           y: y,
           length: dimensions.forward,
           prefix: "h"
         });

    this._dimensions.current = dimensions;
    this._dimensions.lines = [ down, forward ];

    this._path = pathD(
                   xy(this.points.from_x, this.points.from_y),
                   down.path,
                   CURVE_DOWN_RIGHT,
                   forward.path
                 );
  }

  // Since this arrow simply goes from Branch, via Condition A to point B, which is expected
  // to be the next adjacent item, it should not have any overlap issues which would mean
  // nudge() functionality is also not a requirement. The 'down1' line is likely to clash with
  // others coming from the same Branch node, but they are ok to overlap as they should all
  // appear to be a single line.
  nudge(linename) {
    switch(linename) {
      case "down": console.log("DEV HELPER MESSAGE: This can be ignored");
    }
  }
}


class FlowConnectorLine {

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

    switch(config.prefix.charAt(0)) {
      case "h": this.type = HORIZONTAL;
         break;

      case "v": this.type = VERTICAL;
         break;

      default: this.type = "uknown";
    }

    this.range = [config.x, config.y];
  }

  get name() {
    return this._private.name;
  }

  set type(t) {
    this._private.type = t;
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
    var start = (this._private.type == HORIZONTAL) ? points[0] : points[1]; // start from x or y?
    var length = this._private.length;

    // Decide if count goes forward or backward based on line prefix containing minus, or not.
    if(this._private.prefix.search("-") >= 0) {
      for(var i=start; i > (start - length); --i) {
        r.push(i);
      }
    }
    else {
      for(var i=start; i < (start + length); ++i) {
        r.push(i);
      }
    }

    this._private.range = r;
  }

  prop(p) {
    var value;
    switch(p) {
      case "x":
        value = this._private.x;
        break;

      case "y":
        value = this._private.y;
        break;

      case "length":
        value = this._private.length;
        break;

      default: // nothing;
    }
    return value;
  }

  testOnlySvg() {
    var path = createPath(pathD(
                 xy(this._private.x, this._private.y),
                 this.path
               ));
    var $svg = createSvg(path.replace(/(\<path)\s/, "$1 style=\"stroke:red;\" name=\"" + this.name + "\""));
    $svg.addClass("FlowConnectorLine");
    return $svg
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
  var $svg = $(SVG_TAG_OPEN + paths + SVG_TAG_CLOSE);
  return $svg;
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


/******************************************
 * Temporary/development helper functions
 ******************************************/
function createTestSvg(line) {
  var d = pathD(xy(line.x, line.y), line.path);
  var $svg = createSvg(createPath(d));
  var $path = $svg.find("path");
  $svg.addClass("FlowConnectorPath");
  $svg.css("z-index", "2");
  $path.css("stroke", "red");
  $path.attr("stroke-width", "2");
  return $svg;
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
