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
const ARROW_LINE = "<div class=\"pathline\"><span class=\"patharrow\"></span></div>";
const STANDARD_LINE = "<div class=\"pathline\"></div>";
const STANDARD_CURVE = "<div class=\"pathcurve\"></div>";
const LINE_X = "pathlineX";
const LINE_Y = "pathlineY";


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
    var $container = $("<div></div>");
    var type;

    points.xDifference = utilities.difference(points.lX, points.rX);
    points.yDifference = utilities.difference(points.lY, points.rY);
    type = calculateType(points);

    $container.addClass("FlowConnectorPath");
    // TEMPORARY: for development only
    $container.attr("data-from", config.from);
    $container.attr("data-to", config.to);
    $container.attr("data-type", type);
    // ...............................

    this.points = points;
    this.$node = $container;
    this.type = type;

    customiseByType.call(this);
  }
}

function calculateType(points) {
  var sameRow = points.lY == points.rY;
  var forward = points.lX < points.rX;
  var up = points.lY > points.rY;
  var type;

  if(points.yDifference < 5) { // 5 is to give some tolerance for a pixel here or there (e.g. some difference calculations  came out as 2)
    if(forward) {
      type = "forward";
    }
    else {
      type = "backward";
    }
  }
  else {
    if(forward) {
      if(up) {
        type = "forward-up";
      }
      else {
        type = "forward-down";
      }
    }
    else {
      if(up) {
        type = "backward-up";
      }
      else {
        type = "backward-down";
      }
    }
  }
  console.log("type: ", type);
  return type;
}


function customiseByType(type) {
  var $container = this.$node;
  var points = this.points;
  var $element = $("<div><span></span></div>"); // temporary

console.log("difference W: ", points.xDifference + "px");
console.log("difference H: ", points.yDifference + "px");
console.log("points.lY < points.rY: ", points.lY < points.rY);

  switch(this.type) {
    case "backward":
         // TODO: TEMPORARY
         $container.append($element);
         $element.css({
           "border-color": "blue"
         });
         break;
    case "backward-down":
         // TODO: TEMPORARY
         $container.append($element);
         $element.css({
           "border-color": "green"
         });
         break;
    case "backward-up":
         // TODO: TEMPORARY
         $container.append($element);
         $element.css({
           "border-color": "orange"
         });
         break;
    case "forward":
         // TODO: TEMPORARY
         createElementsForForwardPath.call(this);
         $container.append($container);
         break;
    case "forward-up":
         createElementsForForwardUpPath.call(this);
         $container.append($container);
         break;
    case "forward-up-forward-down":
         createElementsForForwardUpForwardDownPath.call(this);
         $container.append($container);
         break;
    default:
         // TODO: TEMPORARY
         // TODO: ONE OF THE EXPECTED TYPES (straight??)
         $container.append($element);
         $element.css({
           "background-color": "yellow",
           "border-color": "blue",
           "border-style": "solid",
           "border-width": "1px",
           height: points.yDifference + "px",
           left: points.lX + "px",
           opacity: 0.5,
           top: (points.lY < points.rY ? points.lY + points.yDifference : points.lY - points.yDifference) + "px",
           width: points.xDifference + "px"
         });

         //$element.text("lY:%s, lX:%s\nrY:%s, rX:%s", points.lY, points.lX, points.rY, points.rX);
         $element.text(JSON.stringify(points).replace("\\", ""));
  }
}

function createElementsForForwardPath() {
  var points = this.points;
  var $line1 = $(ARROW_LINE).addClass(LINE_X);

  $line1.addClass("ForwardPath")
        .css({
           height: points.yDifference + "px",
           left: points.lX + "px",
           top: (points.lY < points.rY ? points.lY + points.yDifference : points.lY - points.yDifference) + "px",
           width: points.xDifference + "px"
         });

  this.$node.append($line1);
}

function createElementsForForwardUpPath() {
  var $line1 = $(STANDARD_LINE).addClass(LINE_X);
  var $line2 = $(STANDARD_LINE).addClass(LINE_Y);
  var $curve1 = $(STANDARD_CURVE);
  var $curve2 = $(STANDARD_CURVE);

  this.$node.addClass("ForwardUpPath")
            .append($line1)
            .append($line2)
            .append($curve1)
            .append($curve2);
}

function createElementsForForwardUpForwarDownPath() {
  var $line1 = $(STANDARD_LINE).addClass(LINE_X);
  var $line2 = $(STANDARD_LINE).addClass(LINE_Y);
  var $line3 = $(STANDARD_LINE).addClass(LINE_Y);
  var $line4 = $(STANDARD_LINE).addClass(LINE_X);
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
