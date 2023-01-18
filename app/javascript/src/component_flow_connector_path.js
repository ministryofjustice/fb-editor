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
const PATH_OVERLAP_MINIMUM = 50; // Minimum amount of overlapping contact point to trigger an overlap situation.
const LINE_PIXEL_TOLERANCE = 2; // Arbitrary number just for some pixel tolerance


/* VIEW SPECIFIC COMPONENT:
 * ------------------------
 *
 * @points (Object) Points required for ConnectorPath dimensions {
 *                      lX & lY: 'from' x+y points
 *                      rX & rY: 'to' x+y points
 *                  }
 * @config (Object) Configurations {
 *                      from: Starting FlowItem of the path.
 *                      to: Destination FlowItem of the path.
 *                      $container: jQuery node for appending element.
 *                      space: Number to add before and after start and end points
 *                             (allows for border compensation of existing css)
 *                  }
 **/
class FlowConnectorPath {

  #config;
  #path;
  #points;
  #prop;

  constructor(points, config) {
    var id = config.id || utilities.uniqueString("flowconnectorpath-");
    var conf = utilities.mergeObjects({
                 container: $(),
                 top: 0,
                 bottom: 0, // Nonsense number as should be set by calculating height of container and passing in.
                 dimensions: {
                    // Base class does not expect to set any values for these.
                    original: {},
                    lines: []
                  }
               }, config);

    // Private
    this.#config = conf;
    this.#path = "";
    this.#points = createConnectorPathPoints(utilities.mergeObjects({
                      via_x: 0, // If the connector needs to go via an certain route
                      via_y: 0  // you can add x/y coordinates to help route it.
                   }, points));

    this.#prop = {
      id: id,
      from: conf.from,
      to: conf.to
    }

  }

  // Because JS doesn't allow inheritance of private variables,
  // we're providing a Getter and setting privately in subclass.
  get config() {
    return this.#config;
  }

  get path() {
    return this.#path;
  }

  get points() {
    return this.#points;
  }

  // Gets the bounding box of the path
  // This is used to check path intersections for the adjustment/nudging routine
  get bounds() {
      return {
        x1: Math.min(this.points.from_x, this.points.to_x, this.points.via_x),
        y1: Math.min(this.points.from_y, this.points.to_y, this.points.via_y),
        x2: Math.max(this.points.from_x, this.points.to_x, this.points.via_x),
        y2: Math.max(this.points.from_y, this.points.to_y, this.points.via_y)
      }
  }

  // Determines if the bounds of 2 paths intersect
  intersects(path) {
    return utilities.intersects(this.bounds, path.bounds);
  }


  // Makeing these readonly access properties because they shouldn't be changed.
  prop(name) {
    var p = this.#prop;
    switch(name) {
      case "id":
           p = this.#prop.id;
           break;

      case "from":
           p = this.#prop.from;
           break;

      case "to":
           p = this.#prop.to;
           break;
    }
    return p;
  }

  // Main function to created the connector view and add functionality.
  // Includes commented out, dev only function useful in development.
  render() {
    var flowConnectorPath = this;

    this.$node = createSvg(createPath(this.path) + createArrowPath(this.points));
    this.$node.addClass("FlowConnectorPath")
              .addClass(this.type)
              .attr("id", this.prop("id"))
              .attr("data-from", this.config.from.id)
              .attr("data-to", this.config.to.id)
              .data("instance", this);

    this.config.container.append(this.$node);

    this.$node.find("path").on("mouseover", function() {
      $(document).trigger("FlowConnectorPathOver", flowConnectorPath);
      flowConnectorPath.$node.addClass("active");
    });

    this.$node.find("path").on("mouseout", function() {
      $(document).trigger("FlowConnectorPathOut", flowConnectorPath);
      flowConnectorPath.$node.removeClass("active");
    });

    // Uncomment for developer helper code only
    //this.makeLinesVisibleForTesting();
  }

  // Return all FlowConnectorLines or just those matching the passed type.
  lines(type="") {
    var lineArr = this.config.dimensions.lines;
    var filtered = [];

    for(var i=0; i<lineArr.length; ++i) {
      if(lineArr[i].type == type) {
        filtered.push(lineArr[i]);
      }
    }
    return type != "" ? filtered : lineArr;
  }

  // Same as the lines() function but does not return lines
  // not required to be included the any overlap comparison.
  linesForOverlapComparison(type="") {
    var lns = this.lines(type);
    var filtered = [];
    for(var i=0; i<lns.length; ++i) {
      if(!lns[i].prop("overlapAllowed")) {
        filtered.push(lns[i]);
      }
    }
    return filtered;
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
    // writing) the following code that is used for the simplistic ForwardUpForwardPath class.
    //
    //   nudge(nH, nV) {
    //     var dimensions = {
    //       horizontal: this.#config.dimensions.current.horizontal - (nH * NUDGE_SPACING),
    //       vertical: this.#config.dimensions.current.vertical - (nV * NUDGE_SPACING)
    //     }
    //
    //     this.path = dimensions;
    //     this.$node.find("path:first").attr("d", this._path);
    //   }
    //
    return false; // Other (active) nudge functions should return true if something was nudged.
  }

  makeLinesVisibleForTesting() {
    // DEVELOPMENT ONLY FUNCTION
    // When debugging problems with creates Lines (used in comparison for overlapping FlowConnectorPaths),
    // this funciton can be called to make things visible and, therefore, a bit easier. See this.build().
    for(var i=0; i<this.config.dimensions.lines.length; ++i) {
      this.config.container.append(this.config.dimensions.lines[i].testOnlySvg());
    }
  }

  avoidOverlap(path) {
    // Don't do anything unles the paths overlap
    if(!this.intersects(path)) return false;

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
    var overlapWasFixed = false;

    if(FlowConnectorPath.compareLines(this, path, "vertical")) {
      overlapWasFixed = true;
    }

    if(FlowConnectorPath.compareLines(this, path, "horizontal")) {
      overlapWasFixed = true;
    };

    return overlapWasFixed;
  }

  #calculatePath() {
    return this.path;
  }

}


FlowConnectorPath.compareLines = function(path, comparisonPath, direction) {
  var lines = path.linesForOverlapComparison(direction);
  var comparisonLines = comparisonPath.linesForOverlapComparison(direction);
  var lineWasNudged = false;

  // Loop over each line in current FlowConnectorPath
  for(var a=0; a < lines.length; ++a) {
    const lineA = lines[a];
    // Compare with each line in the passed FlowConnectorPath
    for(var b=0; b < comparisonLines.length; ++b) {
      const lineB = comparisonLines[b];
      let lineXY = lineA.prop(direction == "vertical" ? "x" : "y");
      let comparisonLineXY = lineB.prop(direction == "vertical" ? "x" : "y");

      // First check if they occupy the same horizontal point/position.
      if(comparisonLineXY >= (lineXY - LINE_PIXEL_TOLERANCE) && comparisonLineXY <= (lineXY + LINE_PIXEL_TOLERANCE)) {

        // Check if the lines are overlapping
        if(lineA.overlaps(lineB)) {
          // console.log("Overlap found between '%s.%s - %s' and '%s.%s - %s'", path.type, lineA.name, path.prop('id'), comparisonPath.type, lineB.name, path.prop('id'));

          // Call the nudge function (may or may not actual need to move the line).
          // If the line is moved we set a variable to report back that action.
          // It is likely the controlling/calling script will want to know so that
          // the comparisons can start again. This will be useful if the movement
          // simply caused the line to be moved from one overlap to cause an
          // overlap with another line.
          if(comparisonPath.nudge(lineB.name)) {
            lineWasNudged = true;
          }
        }
      }
    }
  }

  return lineWasNudged;
}


class ForwardPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward: Math.round(this.points.xDifference)
    }

    // Initialise private inheritance.);
    this.#config = this.config;
    this.#config.dimensions = { original: dimensions  } // Not expected to change.
    this.#calculatePath(dimensions);

    this.type = "ForwardPath";
  }

  get path() {
    return this.#path;
  }

  // Since this arrow simply goes from point A to B, which is expected to
  // be between two adjacent items, it should not have any overlap issues
  // which would mean nudge() functionality is not a requirement.

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;
      let forward = new FlowConnectorLine("forward", {
                      x: x,
                      y: y,
                      length: dimensions.forward,
                      prefix: "h",
                      overlapAllowed: true
                    });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ forward ];
      this.#path = pathD(
                     xy(this.points.from_x, this.points.from_y),
                     forward.path
                   );
    }

    return this.#path;
  }
}


class ForwardUpForwardPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      up: Math.round(this.points.yDifference - (CURVE_SPACING * 2)),
      forward2: Math.round(utilities.difference((this.points.from_x + this.points.via_x), this.points.to_x) - (CURVE_SPACING * 2))
    }

    this.#config = this.config;
    this.#config.dimensions = { original: dimensions }; // dimensions.current will be added in set #calculatePath()
    this.type = "ForwardUpForwardPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "up":
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "forward1":
      case "forward2":
           // no overlap prevention should be required for these.
    }

    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += (forward1.prop("length") + CURVE_SPACING);
      y -= CURVE_SPACING;
      let up = new FlowConnectorLine("up", {
                 x: x,
                 y: y,
                 length: dimensions.up,
                 prefix: "v-"
               });

     x += CURVE_SPACING;
     y -= (up.prop("length") + CURVE_SPACING);
     let forward2 = new FlowConnectorLine("forward2", {
                      x: x,
                      y: y,
                      length: dimensions.forward2,
                      prefix: "h",
                      overlapAllowed: true
                    });

      this.#config.dimensions.current = Object.assign({},dimensions);
      this.#config.dimensions.lines = [ forward1, up, forward2 ];

      this.#path = pathD(
                     xy(this.points.from_x, this.points.from_y),
                     forward1.path,
                     CURVE_RIGHT_UP,
                     up.path,
                     CURVE_UP_RIGHT,
                     forward2.path
                   );
    }

    return this.#path;
  }
}


class ForwardUpForwardDownPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      up: Math.round(utilities.difference(this.points.from_y, config.top)),
      forward2: Math.round(this.points.xDifference - (this.points.via_x + (CURVE_SPACING * 4))),
      down: Math.round(utilities.difference(config.top, this.points.to_y)),
      forward3: 0 // Expected start value
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "ForwardUpForwardDownPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "forward2":
           d.up += NUDGE_SPACING;
           d.down += NUDGE_SPACING;
           nudged = true;
           break;

      case "up":
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "down":
           d.forward2 -= NUDGE_SPACING;
           d.forward3 += NUDGE_SPACING;
           nudged = true;
           break;

      case "forward1":
      case "forward3":
           // no overlap prevention should be required for these.
    }

    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;
      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += forward1.prop("length") + CURVE_SPACING;
      y -= CURVE_SPACING;
      let up = new FlowConnectorLine("up", {
                 x: x,
                 y: y,
                 length: dimensions.up,
                 prefix: "v-"
               });

      x += CURVE_SPACING;
      y -= (up.prop("length") + CURVE_SPACING);
      let forward2 = new FlowConnectorLine("forward2", {
                       x: x,
                       y: y,
                       length: dimensions.forward2,
                       prefix: "h"
                     });

      x += (forward2.prop("length") + CURVE_SPACING);
      y += CURVE_SPACING;
      let down = new FlowConnectorLine("down", {
                   x: x,
                   y: y,
                   length: dimensions.down,
                   prefix: "v"
                 });

      x += CURVE_SPACING;
      y += (down.prop("length") + CURVE_SPACING);
      let forward3 = new FlowConnectorLine("forward3", {
                       x: x,
                       y: y,
                       length: dimensions.forward3,
                       prefix: "h"
                     });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ forward1, up, forward2, down, forward3 ];

      this.#path = pathD(
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

    return this.#path;
  }
}


class ForwardDownBackwardUpPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);

    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      down: Math.round(utilities.difference(this.points.from_y, config.bottom) - (CURVE_SPACING * 2)),
      backward: Math.round(utilities.difference(this.points.from_x + this.points.via_x, this.points.to_x)),
      up: Math.round(utilities.difference(config.bottom, this.points.from_y) + utilities.difference(this.points.from_y, this.points.to_y, false) - (CURVE_SPACING * 2)),
      forward2: 0
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "ForwardDownBackwardUpPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "down":
           d.forward1 -= NUDGE_SPACING;
           d.backward -= NUDGE_SPACING;
           nudged = true;
           break;

      case "up":
           d.backward += NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "backward":
           d.down += NUDGE_SPACING;
           d.up += NUDGE_SPACING;
           nudged = true;

      case "forward1":
           // no overlap prevention should be required for this.
    }

    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += (forward1.prop("length") + CURVE_SPACING);
      y += CURVE_SPACING;
      let down = new FlowConnectorLine("down", {
                   x: x,
                   y: y,
                   length: dimensions.down,
                   prefix: "v"
                 });

      x -= CURVE_SPACING;
      y += (down.prop("length") + CURVE_SPACING);
      let backward = new FlowConnectorLine("backward", {
                       x: x,
                       y: y,
                       length: dimensions.backward,
                       prefix: "h-"
                     });

      x -= (backward.prop("length") + CURVE_SPACING);
      y -= CURVE_SPACING;
      let up = new FlowConnectorLine("up", {
                 x: x,
                 y: y,
                 length: dimensions.up,
                 prefix: "v-"
               });

      x += CURVE_SPACING;
      y -= (up.prop("length") + CURVE_SPACING);
      let forward2 = new FlowConnectorLine("forward2", {
                       x: x,
                       y: y,
                       length: dimensions.forward2,
                       prefix: "h"
                     });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ forward1, down, backward, up, forward2 ];

      this.#path = pathD(
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

    return this.#path;
  }
}

class ForwardDownForwardPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      forward1: Math.round(this.points.via_x - CURVE_SPACING),
      down: Math.round(utilities.difference(this.points.from_y, this.points.to_y) - (CURVE_SPACING * 2)),
      forward2: Math.round( utilities.difference( this.points.from_x + this.points.via_x, this.points.to_x ) - (CURVE_SPACING * 2)),
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "ForwardDownForwardPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "down":
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "forward1":
      case "forward2":
           // no overlap prevention should be required for this.
    }

    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += (forward1.prop("length") + CURVE_SPACING);
      y += CURVE_SPACING;
      let down = new FlowConnectorLine("down", {
                   x: x,
                   y: y,
                   length: dimensions.down,
                   prefix: "v"
                 });

      x += CURVE_SPACING;
      y += (down.prop("length") + CURVE_SPACING);
      let forward2 = new FlowConnectorLine("forward2", {
                       x: x,
                       y: y,
                       length: dimensions.forward2,
                       prefix: "h"
                     });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ forward1, down, forward2 ];

      this.#path = pathD(
                     xy(this.points.from_x, this.points.from_y),
                     forward1.path,
                     CURVE_RIGHT_DOWN,
                     down.path,
                     CURVE_DOWN_RIGHT,
                     forward2.path);
    }

    return this.#path;
  }
}

class DownForwardDownBackwardUpPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);

    var down1 = Math.round(utilities.difference(points.from_y, this.points.via_y));
    var down2 = Math.round(utilities.difference(config.bottom, this.points.via_y));
    var up = Math.round(this.points.from_y - this.points.to_y) + down1 + down2;

    var dimensions = {
      down1: down1 - CURVE_SPACING,
      forward1: Math.round(this.points.via_x - (CURVE_SPACING * 2)),
      down2: down2 - CURVE_SPACING*2,
      backward: Math.round(this.points.via_x + utilities.difference(this.points.from_x, this.points.to_x)),
      up: up - CURVE_SPACING * 2,
      forward2: 0
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "DownForwardDownBackwardUpPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "down2":
           d.forward1 -= NUDGE_SPACING;
           d.backward -= NUDGE_SPACING;
           nudged = true;
           break;

      case "up":
           d.backward += NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "backward":
           d.down2 += NUDGE_SPACING;
           d.up += NUDGE_SPACING;
           nudged = true;
           break;

      case "down1":
      case "forward1":
           // These lines can be ignored because overlaps are tolerated or not relevant.
    }
    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let down1 = new FlowConnectorLine("down1", {
                    x: x,
                    y: y,
                    length: dimensions.down1,
                    prefix: "v",
                    overlapAllowed: true
                  });

      x += CURVE_SPACING;
      y += (down1.prop("length") + CURVE_SPACING);
      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += (forward1.prop("length") + CURVE_SPACING);
      y += CURVE_SPACING;
      let down2 = new FlowConnectorLine("down2", {
                    x: x,
                    y: y,
                    length: dimensions.down2,
                    prefix: "v"
                  });

      x -= CURVE_SPACING;
      y += (down2.prop("length") + CURVE_SPACING);
      let backward = new FlowConnectorLine("backward", {
                       x: x,
                       y: y,
                       length: dimensions.backward,
                       prefix: "h-"
                     });

      x -= (CURVE_SPACING + dimensions.backward);
      y -= CURVE_SPACING;
      let up = new FlowConnectorLine("up", {
                 x: x,
                 y: y,
                 length: dimensions.up,
                 prefix: "v-"
               });

      x += CURVE_SPACING;
      y -= (up.prop("length") + CURVE_SPACING);
      let forward2 = new FlowConnectorLine("forward2", {
                       x: x,
                       y: y,
                       length: dimensions.forward2,
                       prefix: "h"
                     });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ down1, forward1, down2, backward, up, forward2 ];

      this.#path = pathD(
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

    return this.#path;
  }
}


class DownForwardUpPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down: Math.round(utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING),
      forward1: Math.round(points.via_x - (CURVE_SPACING * 2)),
      up: Math.round(utilities.difference(points.via_y, this.points.to_y) - (CURVE_SPACING * 2)),
      forward2: Math.round(utilities.difference(points.from_x, points.to_x) - (points.via_x + CURVE_SPACING))
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "DownForwardUpPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "up":
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "down":
      case "forward1":
      case "forward2":
           // These lines can be ignored because overlaps are tolerated or not relevant.
    }

    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let down = new FlowConnectorLine("down", {
                   x: x,
                   y: y,
                   length: dimensions.down,
                   prefix: "v",
                   overlapAllowed: true
                 });

      x += CURVE_SPACING;
      y += (down.prop("length") + CURVE_SPACING);
      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += (forward1.prop("length") + CURVE_SPACING);
      y -= CURVE_SPACING;
      let up = new FlowConnectorLine("up", {
                 x: x,
                 y: y,
                 length: dimensions.up,
                 prefix: "v-"
               });

      x += CURVE_SPACING;
      y -= (up.prop("length") + CURVE_SPACING);
      let forward2 = new FlowConnectorLine("forward2", {
                       x: x,
                       y: y,
                       length: dimensions.forward2,
                       prefix: "h"
                     });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ down, forward1, up, forward2 ];

      this.#path = pathD(
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

    return this.#path;
  }
}


class DownForwardUpForwardDownPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down1: Math.round(utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING),
      forward1: Math.round(points.via_x - (CURVE_SPACING * 2)),
      up: Math.round(utilities.difference(this.points.via_y, config.top)),
      forward2: Math.round(utilities.difference(points.from_x + this.points.via_x, this.points.to_x) - (CURVE_SPACING * 4)),
      down2: Math.round(points.to_y),
      forward3: 0 // start value
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "DownForwardUpForwardDownPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "up":
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "forward2":
           d.up += NUDGE_SPACING;
           d.down2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "down2":
           d.forward2 -= NUDGE_SPACING;
           d.forward3 += NUDGE_SPACING;
           nudged = true;
           break;

      case "down1":
      case "forward1":
           // These lines can be ignored because overlaps are tolerated or not relevant.
    }

    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let down1 = new FlowConnectorLine("down1", {
                   x: x,
                   y: y,
                   length: dimensions.down1,
                   prefix: "v",
                   overlapAllowed: true
                 });

      x += CURVE_SPACING;
      y += (down1.prop("length") + CURVE_SPACING);
      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += (forward1.prop("length") + CURVE_SPACING);
      y -= CURVE_SPACING;
      let up = new FlowConnectorLine("up", {
                 x: x,
                 y: y,
                 length: dimensions.up,
                 prefix: "v-"
               });

      x += CURVE_SPACING;
      y -= (up.prop("length") + CURVE_SPACING);
      let forward2 = new FlowConnectorLine("forward2", {
                       x: x,
                       y: y,
                       length: dimensions.forward2,
                       prefix: "h"
                     });

      x += (forward2.prop("length") + CURVE_SPACING);
      y += CURVE_SPACING;
      let down2 = new FlowConnectorLine("down2", {
                    x: x,
                    y: y,
                    length: dimensions.down2,
                    prefix: "v"
                  });

      x += CURVE_SPACING;
      y += down2.prop("length") + CURVE_SPACING;
      let forward3 = new FlowConnectorLine("forward3", {
                       x: x,
                       y: y,
                       length: dimensions.forward3,
                       prefix: "h",
                       overlapAllowed: true
                     });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ down1, forward1, up, forward2, down2, forward3 ];

      this.#path = pathD(
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

    return this.#path;
  }
}


class DownForwardDownForwardPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down1: Math.round(utilities.difference(points.from_y, this.points.via_y) - CURVE_SPACING),
      forward1: Math.round(points.via_x - (CURVE_SPACING * 2)),
      down2: Math.round(utilities.difference(points.via_y, this.points.to_y) - (CURVE_SPACING * 2)),
      forward2: Math.round(utilities.difference(points.from_x + this.points.via_x, this.points.to_x) - (CURVE_SPACING * 2))
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "DownForwardDownForwardPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  nudge(linename) {
    var d = Object.assign({}, this.#config.dimensions.current);
    var nudged = false;
    switch(linename) {
      case "down2":
           d.forward1 -= NUDGE_SPACING;
           d.forward2 += NUDGE_SPACING;
           nudged = true;
           break;

      case "down1":
      case "forward1":
      case "forward2":
           // These lines can be ignored because overlaps are tolerated or not relevant.
    }

    this.#calculatePath(d);
    return nudged;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let down1 = new FlowConnectorLine("down1", {
                    x: x,
                    y: y,
                    length: dimensions.down1,
                    prefix: "v",
                    overlapAllowed: true
                  });

      x += CURVE_SPACING;
      y += (down1.prop("length") + CURVE_SPACING);
      let forward1 = new FlowConnectorLine("forward1", {
                       x: x,
                       y: y,
                       length: dimensions.forward1,
                       prefix: "h",
                       overlapAllowed: true
                     });

      x += (forward1.prop("length") + CURVE_SPACING);
      y += CURVE_SPACING;
      let down2 = new FlowConnectorLine("down2", {
                    x: x,
                    y: y,
                    length: dimensions.down2,
                    prefix: "v"
                  });

      x += CURVE_SPACING;
      y += (down2.prop("length") + CURVE_SPACING);
      let forward2 = new FlowConnectorLine("forward2", {
                       x: x,
                       y: y,
                       length: dimensions.forward2,
                       prefix: "h",
                       overlapAllowed: true
                     });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ down1, forward1, down2, forward2 ];

      this.#path = pathD(
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

    return this.#path;
  }
}


class DownForwardPath extends FlowConnectorPath {

  #config;
  #path;

  constructor(points, config) {
    super(points, config);
    var dimensions = {
      down: Math.round(this.points.yDifference - CURVE_SPACING),
      forward: Math.round(this.points.xDifference - CURVE_SPACING)
    }

    this.#config = this.config;

    this.#config.dimensions = { original: dimensions };
    this.type = "DownForwardPath";
    this.#calculatePath(dimensions);
  }

  get path() {
    return this.#path;
  }

  // Since this arrow simply goes from Branch, via Condition A to point B, which is expected
  // to be the next adjacent item, it should not have any overlap issues which would mean
  // nudge() functionality is also not a requirement. The 'down1' line is likely to clash with
  // others coming from the same Branch node, but they are ok to overlap as they should all
  // appear to be a single line.
  nudge(linename) {
    switch(linename) {
      case "down":
      case "forward":
           // These lines can be ignored because overlaps are tolerated or not relevant.
    }
    return false;
  }

  // Get or Set internal _path value
  #calculatePath(dimensions) {
    if(arguments.length) {
      let x = this.points.from_x;
      let y = this.points.from_y;

      let down = new FlowConnectorLine("down", {
                   x: x,
                   y: y,
                   length: dimensions.down,
                   prefix: "v",
                   overlapAllowed: true
                 });

      x += CURVE_SPACING;
      y += (down.prop("length") + CURVE_SPACING);
      let forward = new FlowConnectorLine("forward", {
                      x: x,
                      y: y,
                      length: dimensions.forward,
                      prefix: "h",
                      overlapAllowed: true
                    });

      this.#config.dimensions.current = Object.assign({}, dimensions);
      this.#config.dimensions.lines = [ down, forward ];

      this.#path = pathD(
                     xy(this.points.from_x, this.points.from_y),
                     down.path,
                     CURVE_DOWN_RIGHT,
                     forward.path
                   );
    }

    return this.#path;
  }
}


/* Class used for building and tracking tracking individual lines within a FlowConnectorPath
 **/
class FlowConnectorLine {

  #config;
  #name;
  #range;
  #type;

  // @name   (String) You want this to correspond to the internal dimension name (e.g. 'forward' or 'down')
  // @config (Object) Should be populated with {
  //                    start: 0, // An x or y number depending on type.
  //                    end: 10,  // An x or y number depending on type.
  //                    type: [horizontal|vertical] // String value
  //                  }
  constructor(name, config) {
    this.#name = name;
    this.#config = {
      x: config.x,
      y: config.y,
      length: config.length,
      overlapAllowed: (config.overlapAllowed ? config.overlapAllowed : false),
      prefix: config.prefix
    }

    switch(config.prefix.charAt(0)) {
      case "h": this.#type = HORIZONTAL;
         break;

      case "v": this.#type = VERTICAL;
         break;

      default: this.#type = "uknown";
    }

    this.#range = this.#calculateRange([config.x, config.y]);
  }

  get name() {
    return this.#name;
  }

  get type() {
    return this.#type;
  }

  // Returns a string used for part of an svg <path> d attribute value.
  get path() {
    return this.#config.prefix + this.#config.length
  }

  get range() {
    return this.#range;
  }

  overlaps(line) {
    return utilities.overlaps(this.range, line.range, PATH_OVERLAP_MINIMUM);
  }

  // Returns a particular configuration property
  prop(p) {
    var value;
    switch(p) {
      case "overlapAllowed":
        value = this.#config.overlapAllowed;
        break;
      case "x":
        value = this.#config.x;
        break;

      case "y":
        value = this.#config.y;
        break;

      case "length":
        value = this.#config.length;
        break;

      default: // nothing;
    }
    return value;
  }

  testOnlySvg() {
    var path = createPath(pathD(
                 xy(this.#config.x, this.#config.y),
                 this.path
               ));
    var $svg = createSvg(path.replace(/(\<path)\s/, "$1 style=\"stroke:red;\" name=\"" + this.#name + "\""));
    $svg.addClass("FlowConnectorLine");
    return $svg
  }

  // PRIVATE METHODS

  #calculateRange(points /* [x, y] */) {
    var start = (this.#type == HORIZONTAL) ? points[0] : points[1]; // start from x or y?
    var length = this.#config.length;
    var end;

    // Decide if count goes forward or backward based on line prefix containing minus, or not.
    if(this.#config.prefix.search("-") >= 0) {
        end = start - length;
    }
    else {
      end = start + length;
    }

    return {
      start: Math.min(start,end),
      end: Math.max(start, end)
    }
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


/*************************************
 * Make available for importing.
 *************************************/

module.exports = {
  FlowConnectorPath: FlowConnectorPath,
  ForwardPath: ForwardPath,
  ForwardUpForwardPath: ForwardUpForwardPath,
  ForwardUpForwardDownPath: ForwardUpForwardDownPath,
  ForwardDownForwardPath: ForwardDownForwardPath,
  ForwardDownBackwardUpPath: ForwardDownBackwardUpPath,
  DownForwardDownBackwardUpPath: DownForwardDownBackwardUpPath,
  DownForwardUpPath: DownForwardUpPath,
  DownForwardUpForwardDownPath: DownForwardUpForwardDownPath,
  DownForwardDownForwardPath: DownForwardDownForwardPath,
  DownForwardPath: DownForwardPath
}
