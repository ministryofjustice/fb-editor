/**
 * Services Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the FB Editor service views.
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/



const utilities = require('./utilities');
const FormDialog = require('./component_dialog_form');
const DefaultController = require('./controller_default');
const ConnectorPath = require('./component_flow_connector_path');
const PageMenu = require('./component_page_menu');
const ConnectionMenu = require('./component_connection_menu');

const COLUMN_SPACING = 100;
const SELECTOR_FLOW_BRANCH = ".flow-branch";
const SELECTOR_FLOW_CONDITION = ".flow-condition";
const SELECTOR_FLOW_ITEM = ".flow-item";
const SELECTOR_FLOW_LINE_PATH = ".FlowConnectorPath path:first-child";


class ServicesController extends DefaultController {
  constructor(app) {
    super(app);

    switch(app.page.action) {
      case "edit":
        ServicesController.edit.call(this);
        break;
    }
  }
}


/* CONTROLLER VIEW ACTION:
 * -----------------------
 * Setup for the Edit action
 **/
ServicesController.edit = function() {
  var view = this; // Just making it easlier to understand the context.
  view.$flowOverview = $("#flow-overview");
  view.$flowDetached = $("#flow-detached");

  createPageAdditionDialog(view);
  createPageMenus(view);
  createConnectionMenus(view); 

  if(view.$flowOverview.length) {
    layoutFormFlowOverview(view);
  }

  if(view.$flowDetached.length) {
    layoutDetachedItemsOveriew(view);
  }

  // Reverse the Brief flash of content quickfix.
  $("#main-content").css("visibility", "visible");
}


/* VIEW SPECIFIC COMPONENT:
 * ------------------------
 * Positionable item in the flow
 **/
class FlowItem {
  constructor($node, config) {
    $node.data("instance", this);
    $node.addClass("FlowItem");

    this.$node = $node;
    this.id = $node.attr("data-fb-id");
    this.next = $node.attr("data-next");
    this.row = config.row;
    this.column = config.column;
    this.coords = {
      x_in: config.x_in,
      x_out: config.x_out,
      y: config.y,
    };

  }
}


/* VIEW SPECIFIC COMPONENT:
 * ------------------------
 * Simple item to mimic FlowItem-like object but for the branch conditions.
 * Could also be renamed FlowBranchCondition class but we're trying to
 * highlight the similarities to a FlowItem (which could also be split into
 * two separate classes of FlowPage and FlowBranch but keeping things simple).
 **/
class FlowConditionItem {
  constructor($node, config) {
    $node.data("instance", this);
    $node.addClass("FlowConditionItem");

    this.$node = $node;
    this.from = $node.attr("data-from");
    this.next = $node.attr("data-next");
    this.row = config.row;
    this.column = config.column;
  }
}

/* VIEW SETUP FUNCTION:
 * --------------------
 * Finds the (in page) form that can add a new page and enhances with Dialog component
 * effect and necessary type selection (with error handling) functionality.
 **/
function createPageAdditionDialog(view) {
  var $dialog = $("[data-component='PageAdditionDialog']"); // Expect only one
  var $form = $dialog.find("form");
  var $errors = $dialog.find(".govuk-error-message");

  view.pageAdditionDialog = new FormDialog($dialog, {
    autoOpen: $errors.length ? true: false,
    view: view,
    cancelText: $dialog.attr("data-cancel-text"),
    selectorErrors: ".govuk-error-message",
    removeErrorClasses: "govuk-form-group--error",
    close: function() {
      // Reset to remove any lingering values.
      utilities.updateHiddenInputOnForm($form, "page[page_type]", "");
      utilities.updateHiddenInputOnForm($form, "page[component_type]", "");
    }
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the context menus for each flow item within an overview layout.
 **/
function createPageMenus(view) {
  $("[data-component='ItemActionMenu']").each((i, el) => {
    var menu = new PageMenu($(el), {
      view: view,
      preventDefault: true, // Stops the default action of triggering element.
      menu: {
        position: { at: "right+2 top-2" }
      }
    });

    view.addLastPointHandler(menu.activator.$node);
  });
}
/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the connection menus for each flow item within an overview layout.
 **/
function createConnectionMenus(view) {
  $("[data-component='ConnectionMenu']").each((i, el) => {
    var menu = new ConnectionMenu($(el), {
      view: view,
      preventDefault: true, // Stops the default action of triggering element.
      menu: {
        position: { at: "right+2 top-2" }
      }
    });

    view.addLastPointHandler(menu.activator.$node);
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the main overview layout for form to get the required design.
 *
 * IMPORTANT: We are intentionally calling adjustOverviewHeight() twice.
 *            Reason for this is because some lines are not getting their
 *            correct dimensions (observed DownForwardDownBackwardsUp).
 *            Calling adjustOverviewHeight() after positioning Flow items
 *            means the container expands to the height of items. Then,
 *            calling it a second time, after the FlowConnectorPaths have
 *            been drawn, recalculates the height of container to include
 *            any lines that have gone outside the original boundary. This
 *            is a little annoying but, without the first call, things
 *            appear to position correctly with the noticed exception of
 *            the line type mentioned earlier. Double call is quickfix.
**/
function layoutFormFlowOverview(view) {
  var $container = view.$flowOverview;
  createAndPositionFlowItems($container);

  // TEMPORARY: BRANCHING FEATURE FLAG
  if(!view.features.branching) {
    positionAddPageButton();
  }
  adjustOverviewHeight($container);
  applyPageFlowConnectorPaths($container);
  applyBranchFlowConnectorPaths($container);
  applyRouteEndFlowConnectorPaths($container);
  adjustOverlappingFlowConnectorPaths($container);
  adjustBranchConditionPositions($container);
  adjustOverviewHeight($container);
  adjustOverviewWidth($container);
  applyOverviewScroll($container);
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the detatched overview layout to get the required design.
 * Note: We treat the scrolling a bit different from the main layout
 * area since there can be multiple, individual, layout groups and
 * also the expander effect to take into account. This means we need
 * to jump through a couple hoops by changing the section width and
 * compensating for that with positioning the section title.
 *
 * IMPORTANT: We are intentionally calling adjustOverviewHeight() twice.
 *            Reason for this is because some lines are not getting their
 *            correct dimensions (observed DownForwardDownBackwardsUp).
 *            Calling adjustOverviewHeight() after positioning Flow items
 *            means the container expands to the height of items. Then,
 *            calling it a second time, after the FlowConnectorPaths have
 *            been drawn, recalculates the height of container to include
 *            any lines that have gone outside the original boundary. This
 *            is a little annoying but, without the first call, things
 *            appear to position correctly with the noticed exception of
 *            the line type mentioned earlier. Double call is quickfix.
**/
function layoutDetachedItemsOveriew(view) {
  var $container = view.$flowDetached;
  var $title = $("h2", $container);
  var offsetLeft = $container.offset().left;
  var expander = $container.data("instance"); // Element is set as an Expander Component.

  // Make sure it's open on page load
  expander.open();

  // Expand the width of the section.
  $container.css({
    left:  ~(offsetLeft),
    position: "relative",
    width: window.innerWidth
  });

  // Compensate for previous change.
  $title.css({
    left: offsetLeft + "px",
    position: "relative"
  });

  // Add required scrolling to layout groups.
  $(".flow-detached-group", $container).each(function() {
    var $group = $(this);
    createAndPositionFlowItems($group);
    adjustOverviewHeight($group);
    applyPageFlowConnectorPaths($group);
    applyBranchFlowConnectorPaths($group);
    adjustOverlappingFlowConnectorPaths($group);
    adjustBranchConditionPositions($group);
    adjustOverviewHeight($group);
    adjustOverviewWidth($group);
    applyOverviewScroll($group);
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Main function to find and position flow items (pages/branches/spacers)
 * within an overview layout.
**/
function createAndPositionFlowItems($overview) {
  var $columns = $(".column", $overview);
  var rowHeight = utilities.maxHeight($(SELECTOR_FLOW_ITEM, $overview)); // Design is thumbnail + same for spacing.
  var left = 0;

  // Loop over found columns created from the flow
  $columns.each(function(column) {
    var $column = $(this);
    var $items = $(SELECTOR_FLOW_ITEM, this);
    var conditionsLeft = 0;
    var top = 0; // TODO: Where should this come from? (see also COLUMN_SPACING)

    $items.each(function(row) {
      var $item = $(this);
      var itemWidth = $item.outerWidth();
      var conditionTop = (rowHeight / 4);
      var $conditions = $(SELECTOR_FLOW_CONDITION, this);

      // First, bring it out of the column because we don't need it.
      // We will remove the columns later.
      $column.before($item);

      // Creates FlowItem instances (boxes and diamonds) with positions data.
      new FlowItem($item, {
        x_in: left,
        x_out: left + $item.outerWidth(),
        y: top + (rowHeight / 4),
        column: column,
        row: row
      });

      // Position flow item node.
      $item.css({
        left: left + "px",
        position: "absolute",
        top: top + "px"
      });

      if($conditions.length) {
        conditionsLeft = itemWidth + utilities.maxWidth($conditions);
      }

      // Positions any conditions nodes (bubbles) with this loop
      $conditions.each(function(index) {
        var $condition = $(this);
        $condition.css({
          left: itemWidth,
          position: "absolute",
          top: conditionTop
        });

        // Creates FlowConditionItem instances (speach bubbles) with simple data.
        new FlowConditionItem($condition, {
          column: column,
          row: row + index
        });

        conditionTop += rowHeight;
      });

      top += rowHeight;
    });

    if(conditionsLeft) {
      // Adjust distance based on any found conditions
      left += conditionsLeft
    }
    else {
      // Adjust distance based just on column width
      left += utilities.maxWidth($items);
    }

    left += COLUMN_SPACING; // Use same spacing regardless of condition found, or not.
  });

  // Ditch the columns.
  $columns.remove();
}


/*
 * VIEW HELPER FUNCTION:
 * ---------------------
 * Position of BranchCondition text is below the FlowConnectorPath lines, which helps make the initial
 * calculations for items and line, etc. However, the design wants the text to be above the lines.
 **/
function adjustBranchConditionPositions($overview) {
  var strokeWidth = $(".FlowConnectorPath path").eq(0).css("stroke-width") || "";
  var lineHeight = Number(strokeWidth.replace("px", "")) || 0;
  $overview.find(".flow-expression").each(function() {
    var $this = $(this);
    var expressionHeight = Number($this.height()) || 0;
    $this.css({
      position: "relative",
      top: "-" + (expressionHeight + lineHeight) + "px"
    });
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Because flow items are absolutely positioned, they will take up
 * no space in their container. To compensate for this lack of
 * container height, we manually calculate the required height and
 * apply dimensional adjustments. 
 **/
function adjustOverviewHeight($overview) {
  var $items = $([SELECTOR_FLOW_ITEM, SELECTOR_FLOW_CONDITION, SELECTOR_FLOW_LINE_PATH].join(", "), $overview);
  var bottomNumbers = [];
  var topNumbers = [];
  var top, bottom, topOverlap, height;

  $items.each(function(index) {
    var $item = $(this);
    // jquery.offset() always returns 0,0 in Safari for scg elements
    // so we use native getBoundingClientRect instead which returns correct values
    var top = $item[0].getBoundingClientRect().y + window.scrollY;
    bottomNumbers.push(top + $item.height());
    topNumbers.push(top);
  });
  
  top = utilities.lowestNumber(topNumbers);
  bottom = utilities.highestNumber(bottomNumbers);
  topOverlap = $overview.offset().top - top;
  height = bottom - top;

  // If the paths expand outside the top of the top of the overview area
  // then the topOverlap will have capture the measurement of by how much.
  // Move the overview area down to avoid paths overlapping content above.
  if(topOverlap > 0) {
    $overview.css("top", topOverlap + "px");
  }

  // Adjustment to make the height over overview area contain the height
  // of all flow items and paths within it.
  if(height > $overview.height()) {
    $overview.css("height", height + "px");
  }
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Due to the flow items and paths being positioned by absolute measurements,
 * the containing (parent) element will not be able to calculate and set
 * correct width dimensions. This function will detect the required width
 * based on calculations of content positions.
 **/
function adjustOverviewWidth($overview) {
  var $items = $([SELECTOR_FLOW_ITEM, SELECTOR_FLOW_CONDITION, SELECTOR_FLOW_LINE_PATH].join(", "), $overview);
  var leftNumbers = [];
  var rightNumbers = [];
  var left, right;

  $items.each(function() {
    var $item = $(this);
    var offsetLeft = Math.ceil($item.offset().left);
    leftNumbers.push(offsetLeft);
    rightNumbers.push(offsetLeft + $item.width());
  });

  left = utilities.lowestNumber(leftNumbers);
  right = utilities.highestNumber(rightNumbers);
  $overview.width((right - left) + "px");
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * To try and fix scrolling issues for the form overview
 * when there are too many thumbnails to fix on the one page view.
 **/
function applyOverviewScroll($overview) {
  var $container = $("<div></div>");
  var $main = $("#main-content");
  var timeout;

  $container.addClass("FlowOverviewScrollFrame");
  $overview.before($container);
  $container.append($overview);

  adjustScrollDimensionsAndPosition($container);

  $(window).on("resize", function() {
    clearTimeout(timeout);
    $main.css("visibility", "hidden");
    timeout = setTimeout(function() {
      $container.get(0).style = ""; // reset everything
      adjustScrollDimensionsAndPosition($container);
      $main.css("visibility", "visible");
    }, 1500);
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Sort out the required dimensions and position for the scrollable area.
 **/
function adjustScrollDimensionsAndPosition($container) {
  const margin = 30; // Based on assumed 30x2 padding (TODO: figure out dynamic/auto method not hardcoded).
  const menuSpacer = 50; // Arbitrary number designed to allow any context menu to fit in container width.
  var viewWidth = window.innerWidth - (margin * 2);
  var containerWidth = $container.get(0).scrollWidth;
  var offsetLeft = $container.offset().left;

  if(containerWidth > viewWidth) {
    // position container width to max left and constrain width
    $container.css({
      left: ~(offsetLeft - margin) + "px",
      padding: "0 " + menuSpacer + " 0 0", // 100 is just arbitrary  extra spacing for opening menus
      width: viewWidth + "px"
    });
  }
  else {
    // centre the container
    $container.css({
      left: ~(offsetLeft - ((viewWidth - containerWidth) / 2)) + "px",
      width: containerWidth + "px"
    });
  }
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Function to apply the arrows (visual conntectors) that indicate the paths
 * between page objects within a flow.
 *
 * Note: Due to Branches working a little differently in terms of arrow
 * design, they are excluded from this function and put in one of their own.
 **/
function applyPageFlowConnectorPaths($overview) {
  var $items = $overview.find('.flow-page[data-next]:not([data-next="trailing-route"])');
  var rowHeight = utilities.maxHeight($items); // There's always a starting page.

  $items.each(function() {
    var $item = $(this);
    var next = $item.data("next");
    var fromX = $item.position().left + $item.outerWidth() + 1; // + 1 for design spacing
    var fromY = $item.position().top + (rowHeight / 4);
    var $next = $("[data-fb-id=" + next + "]", $overview);
    var toX = $next.position().left - 1; // - 1 for design spacing
    var toY = $next.position().top + (rowHeight / 4);

    calculateAndCreatePageFlowConnectorPath({
      from_x: fromX,
      from_y: fromY,
      to_x: toX,
      to_y: toY,
      via_x: COLUMN_SPACING - 20 // 25 because we don't want lines to start at edge of column space
      }, {
      from: $item.data("instance"),
      to: $next.data("instance"),
      container: $overview,
      top: 0,                     // TODO: Is this and the height below the best way to position
      bottom: $overview.height()  //       backward and skip forward lines to the boundaries?
    });
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Function to apply the arrows (visual conntectors) that indicate the paths
 * between branch (and condition) objects within a flow.
 *
 * Note: Branches arrows are a bit different from those between pages, so
 * dealing with them separately from other page arrows.
 **/
function applyBranchFlowConnectorPaths($overview) {
  var $flowItemElements = $overview.find(SELECTOR_FLOW_ITEM);
  var rowHeight = utilities.maxHeight($flowItemElements);

  $flowItemElements.filter(SELECTOR_FLOW_BRANCH).each(function() {
    var $branch = $(this);
    var branchX = $branch.position().left + $branch.outerWidth() + 1; // + 1 for design gap
    var branchY = $branch.position().top + (rowHeight / 2);
    var branchWidth = $branch.outerWidth();
    var $conditions = $branch.find(SELECTOR_FLOW_CONDITION);

    $conditions.each(function(index) {
      var $condition = $(this);
      var condition = $condition.data("instance"); // FlowConditionItem
      var $destination = $("[data-fb-id=" + $condition.data("next") + "]", $overview);
      var destination = $destination.data("instance"); // FlowItem

      // --------------------------------------------------------------------------------------------
      // TODO: Temporary hack to prevent missing destination item bug  breaking the layout
      // https://trello.com/c/iCDLMDgo/1836-bug-branchcondition-destination-page-is-in-detached-items
      if($destination.length < 1) return true;
      // --------------------------------------------------------------------------------------------

      var destinationX = $destination.position().left;
      var destinationY = $destination.position().top + (rowHeight / 4);
      var conditionX = (branchWidth / 2) + $condition.outerWidth(true) - 25 // 25 because we don't want lines to start at edge of column space
      var conditionY = $branch.position().top + $condition.position().top;
      var conditionColumn = condition.column;
      var conditionRow = condition.row;
      var destinationColumn = destination.column;
      var destinationRow = destination.row;
      var backward = conditionColumn > destinationColumn;
      var sameColumn = (conditionColumn == destinationColumn);
      var sameRow = (conditionRow == destinationRow);
      var firstConditionItem = (index == 0);
      var up = conditionRow > destinationRow;
      var nextColumn = (conditionColumn + 1 == destinationColumn);
      var config = {
            container: $overview,
            from: $branch.data("instance"), // Should be FlowItem instance
            to: $destination.data("instance"), // Should be FlowItem instance
            via: $condition,
            top: 0,                     // TODO: Is this and the height below the best way to position
            bottom: $overview.height()  //       backward and skip forward lines to the boundaries?
          };

      if(backward || sameColumn) {

        // If on the same row but destination  behind the current condition
        new ConnectorPath.DownForwardDownBackwardUpPath({
          from_x: branchX - (branchWidth / 2),
          from_y: branchY,
          to_x: destinationX,
          to_y: destinationY,
          via_x: conditionX,
          via_y: conditionY
        }, config);
      }
      else {
        // FORWARD

        if(firstConditionItem && sameRow) {
          // Create straight path to go from right corner of the branch
          // to the x/y coordinates of the related 'next' destination.
          new ConnectorPath.ForwardPath({
            from_x: branchX,
            from_y: branchY - (rowHeight / 4),
            to_x: destinationX,
            to_y: destinationY
          }, config);
        }
        else {
          // NOT FIRST CONDITION ITEM

          if(sameRow) {

            // All other 'standard' BranchConditions expected to be Down and Forward
            // with the starting point from bottom and centre of the Branch item.
            new ConnectorPath.DownForwardPath({
              from_x: branchX - (branchWidth / 2), // Half width because down lines go from centre
              from_y: branchY,
              to_x: destinationX,
              to_y: destinationY
            }, config);
          }
          else {
            // NOT SAME ROW

            if(up) {
              if(nextColumn) {

                new ConnectorPath.DownForwardUpPath({
                  from_x: branchX - (branchWidth / 2),
                  from_y: branchY,
                  to_x: destinationX,
                  to_y: destinationY,
                  via_x: conditionX,
                  via_y: conditionY
                }, config);
              }
              else {
                // NOT NEXT COLUMN
                new ConnectorPath.DownForwardUpForwardDownPath({
                  from_x: branchX - (branchWidth / 2),
                  from_y: branchY,
                  to_x: destinationX,
                  to_y: destinationY,
                  via_x: conditionX,
                  via_y: conditionY
                }, config);
              }
            }
            else {
              // DOWN

              new ConnectorPath.DownForwardDownForwardPath({
                from_x: branchX - (branchWidth / 2),
                from_y: branchY,
                to_x: destinationX,
                to_y: destinationY,
                via_x: conditionX,
                via_y: conditionY
              }, config);
            }
          }
        }
      }

    });
  });
}
function applyRouteEndFlowConnectorPaths($overview) {
  var $items = $overview.find('.flow-page[data-next="trailing-route"]');
  var rowHeight = utilities.maxHeight($items); // There's always a starting page.

  $items.each(function() {
    var $item = $(this);
    var fromX = $item.position().left + $item.outerWidth() + 1; // + 1 for design spacing
    var fromY = $item.position().top + (rowHeight / 4);
    var toX = fromX + 100; // - 1 for design spacing
    var toY = fromY;

    new ConnectorPath.ForwardPath({
        from_x: fromX,
        from_y: fromY,
        to_x: toX,
        to_y: toY,
        via_x: COLUMN_SPACING - 20 // 25 because we don't want lines to start at edge of column space
      }, {
        from: $item.data("instance"),
        to: $item.data("instance"),
        container: $overview,
        top: 0,                     // TODO: Is this and the height below the best way to position
        bottom: $overview.height()  //       backward and skip forward lines to the boundaries?
      }); 

    
  });
}

/* VIEW HELPER FUNCTION:
 * ---------------------
 * Finds and loops over each FlowConnectorPaths calling the avoidOverlap function.
 * Within each iteration, each of the other FlowConnectorPaths are passed in for
 * comparison. The FlowConnectorPaths.avoidOverlap() function will handle the rest.
 *
 * @$overview (jQuery node) Overview container for form layout.
 *
 * Note: In an effort to try and save some computing time, we're excluding the
 * ForwardPath FlowConnectorPaths because they have no nudge functionality and
 * should not have any issues with overlapping. They are the ones that go in a
 * straight line between Page A ---> Page B.
 **/
function adjustOverlappingFlowConnectorPaths($overview) {
  const recursionLimit = 50; // This is a safety feature for the while loop.
  var $paths = $overview.find(".FlowConnectorPath").not(".ForwardPath, .DownForwardPath"); // Filter out Paths we can ignore to save some processing time
  var somethingMoved;
  var numberOfPaths = $paths.length;
  var keepChecking = $paths.length > 0; 
  var loopCount = 1;

  do {
    somethingMoved = false;
    $paths.each(function(count) {
      var numberChecked = (count + 1); // zero index workaround
      var $path = $(this);
      var path = $path.data("instance");

      $paths.each(function() { // or $paths.not($path).each
        var $current = $(this);
        var current = $current.data("instance");

        if(path.id != current.id) {

          // Call the overlap avoidance functionality and register
          // if anything was moved (reported by its return value).
          if(path.avoidOverlap(current)) {
            somethingMoved = true;
            return false;
          }
        }
      });

      // If something has moved, we wil want to start again. Reason
      // for this is because we may have simply moved one overlapping
      // line to overlap with another. There's little point in doing
      // that will all because you'll just be shifting overlaps to a
      // new position, and still have overlaps at the end. Restarting
      // means, eventually, you should end up without any overlaps.
      if(somethingMoved) {
        return false;
      }

      // If nothing was moved then we should find outselves here.
      // When we have gone through all paths, without any changes
      // (moved items) the condition should be true. This should
      // then exit the do...while loop.
      keepChecking = (numberChecked < numberOfPaths);
    });

    loopCount++;
    if(loopCount >= recursionLimit) {
      console.error("Oops! Somethign may have gone wrong. The overlap loop has gone round %d times and tripped the limit.", recursionLimit);
    }

  } while(keepChecking && loopCount < recursionLimit);
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Function uses the from/to relationship of Flow Items and any attributes awarded in the
 * createAndPositionFlowItems() function to help determine the connector path type required.
 *
 * @points (Object) Properties for x/y coordinates (see FlowConnectorPath Class)
 * @config (Object) Various items/properties required by FlowConnectorPath Class.
 **/
function calculateAndCreatePageFlowConnectorPath(points, config) {
  var columnItem = Number(config.from.column);
  var columnNext = Number(config.to.column);
  var rowItem = Number(config.from.row);
  var rowNext = Number(config.to.row);
  var forward = columnItem < columnNext;
  var sameRow = (rowItem == rowNext);
  var up = rowItem > rowNext;
  var destinationInNextColumn = utilities.difference(columnItem, columnNext) == 1;

  if(sameRow) {
    if(forward) {
      new ConnectorPath.ForwardPath(points, config);
    }
    else {
      new ConnectorPath.ForwardDownBackwardUpPath(points, config);
    }
  }
  else {
    if(forward) {
      if(up) {
        if(destinationInNextColumn) {
          new ConnectorPath.ForwardUpPath(points, config);
        }
        else {
          new ConnectorPath.ForwardUpForwardDownPath(points, config);
        }
      }
      else {
        new ConnectorPath.ForwardDownForwardPath(points, config);
      }
    }
    else {
      if(up) {
        new ConnectorPath.ForwardDownBackwardUpPath(points, config);
      }
    }
  }
}


module.exports = ServicesController;
