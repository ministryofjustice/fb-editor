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
const SINGLE_LINE = "<div class=\"pathLine\"><span class=\"pathArrow\"></span></div>";
const MULTI_LINE = "<path></path>";
const LINE = "<path></path>";
const LINE_X_CLASS = "pathLineX";
const LINE_Y_CLASS = "pathLineY";
const CURVE_X_CLASS = "pathCurveX";
const CURVE_Y_CLASS = "pathCurveY";
const SPACER = 25;


/* VIEW SPECIFIC COMPONENT:
 * ------------------------
 *
 * @points (Object) Points required for ConnectorPath dimensions {
 *                      lX & lY: 'from' x+y points
 *                      rX & rY: 'to' x+y points
 *                  }
 * @config (Object) Configurations {
 *                      from: id of starting item
 *                      to: 'next' value of destination item
 *                      $container: jQuery node for appending element.
 *                      space: Number to add before and after start and end points
 *                             (allows for border compensation of existing css)
 *                  }
 **/
class FlowConnectorPath {
  constructor(points, config) {
    var type;

    points.xDifference = utilities.difference(points.lX, points.rX);
    points.yDifference = utilities.difference(points.lY, points.rY);

    this._config = config;
    this.points = points;
    this.type = calculateType(points);
    this.$node = buildByType.call(this);

    this.$node.addClass("FlowConnectorPath")
              .addClass(this.type)
              .attr("height", "0")
              .attr("width", "0")
              .attr("data-from", config.from)
              .attr("data-to", config.to);
  }
}

function calculateType(points) {
  var sameRow = points.lY == points.rY;
  var forward = points.lX < points.rX;
  var up = points.lY > points.rY;
  var type;

  if(points.yDifference < 5) { // 5 is to give some tolerance for a pixel here or there (e.g. some difference calculations  came out as 2)
    if(forward) {
      type = "ForwardPath";
    }
    else {
      type = "BackwardPath";
    }
  }
  else {
    if(forward) {
      if(up) {
        type = "ForwardUpPath";
      }
      else {
        type = "ForwardDownPath";
      }
    }
    else {
      if(up) {
        type = "BackwardUpPath";
      }
      else {
        type = "BackwardDownPath";
      }
    }
  }
  console.log("type: ", type);
  return type;
}


function buildByType(type) {
  var points = this.points;
  var paths = "";
//console.log("difference W: ", points.xDifference + "px");
//console.log("difference H: ", points.yDifference + "px");
//console.log("points.lY < points.rY: ", points.lY < points.rY);

  switch(this.type) {
    case "BackwardPath":
         // TODO...
    case "BackwardDownPath":
         // TODO...
         break;
    case "BackwardUpPath":
         // TODO...
         break;
    case "ForwardPath":
         paths = createElementsForForwardPath.call(this);
         break;
    case "ForwardUpPath":
         // TODO... in progress
//         createElementsForForwardUpPath.call(this);
//         $container.append($container);
         break;
    case "ForwardUpForwardDownPath":
         // TODO... not done yet
//         createElementsForForwardUpForwardDownPath.call(this);
//         $container.append($container);
         break;
    default:
         // TODO: What will default be (forward??)
         console.log("DEFAULT: ", JSON.stringify(points).replace("\\", ""));
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

function createElementsForForwardPath() {
  var points = this.points;
  var x1 = points.lX;
  var y1 = (points.lY < points.rY ? points.lY + points.yDifference : points.lY - points.yDifference);
  var width = "h" + points.xDifference;
  var paths = "<path d=\"" + pathD(xy(x1, y1), width) + "\"></path>";
  paths += createArrowPath(x1 + points.xDifference, y1);
  return paths;
}

function createElementsForForwardUpPath() {
  var points = this.points;
  var $line1 = $(STANDARD_LINE).addClass(LINE_X_CLASS);
  var $line2 = $(STANDARD_LINE).addClass(LINE_Y_CLASS);
  var $curve1 = $(STANDARD_CURVE).addClass(CURVE_Y_CLASS);
  var $curve2 = $(STANDARD_CURVE);
  var height1 = points.yDifference;
  var y1 = Number(points.lY < points.rY ? points.lY + points.yDifference : points.lY - points.yDifference);
  var y2 =  Number(points.yDifference + y1);
  var width1 = points.xDifference - SPACER;

  $line1.css({
          left: points.lX + "px",
          top: y2 + "px",
          width: width1 + "px"
        });

//console.warn("$curve1: ", $caurve1);
//console.warn("curveSize: ", this._config.curveSize);

  $curve1.css({
           left: Number((points.lX + width1) - this._config.curveSize) + "px",
           top: Number(y2 - this._config.curveSize) + "px"
         });

  $line2.css({
          height: points.yDifference + "px",
          left: Number(points.lX + width1) + "px",
          top: y1 + "px"
        });

  this.$node.addClass("ForwardUpPath")
            .append($line1)
            .append($line2)
            .append($curve1)
            .append($curve2);
}

function createElementsForForwardUpForwarDownPath() {
  var $line1 = $(STANDARD_LINE).addClass(LINE_X_CLASS);
  var $line2 = $(STANDARD_LINE).addClass(LINE_Y_CLASS);
  var $line3 = $(STANDARD_LINE).addClass(LINE_Y_CLASS);
  var $line4 = $(STANDARD_LINE).addClass(LINE_X_CLASS);
  var $curve1 = $(STANDARD_CURVE);
  var $curve2 = $(STANDARD_CURVE);
  var $curve3 = $(STANDARD_CURVE);
  var $curve4 = $(STANDARD_CURVE);

  this.$node.addClass("ForwardUpForwardDownPath")
            .append($line1)
            .append($line2)
            .append($line3)
            .append($line4)
            .append($curve1)
            .append($curve2)
            .append($curve3)
            .append($curve4);
}


// Make available for importing.
module.exports = FlowConnectorPath;
