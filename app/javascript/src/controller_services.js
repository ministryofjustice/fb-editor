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
 **/



const utilities = require('./utilities');
const DialogForm = require('./component_dialog_form')
const DefaultController = require('./controller_default');
const FlowItem = require('./component_flow_item');
const FlowConditionItem = require('./component_flow_condition_item');
const ConnectorPath = require('./component_flow_connector_path');
const PageMenu = require('./components/menus/page_menu');
const ConnectionMenu = require('./components/menus/connection_menu');
const Expander = require('./component_expander');

const COLUMN_SPACING = 100;
const SELECTOR_FLOW_BRANCH = ".flow-branch";
const SELECTOR_FLOW_CONDITION = ".flow-condition";
const SELECTOR_FLOW_ITEM = ".flow-item";
const SELECTOR_FLOW_LINE_PATH = ".FlowConnectorPath path:first-child";
const SELECTOR_FLOW_DETACHED_GROUP = ".flow-detached-group";


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
  view.$flowStandalone = $("#flow-standalone-pages");
  view.page.flowItemsRowHeight = utilities.maxHeight($(SELECTOR_FLOW_ITEM).eq(0)); // There is always a Start page.

  createPageAdditionDialog(view);
  createPageMenus(view);
  createConnectionMenus(view);
  createExpanderComponents();

  if(view.$flowOverview.length) {
    layoutFormFlowOverview(view);
  }

  if(view.$flowDetached.length) {
    layoutDetachedItemsOverview(view);
  }

  addServicesContentScrollContainer(view);
  view.ready();

  const flowLayoutTime = performance.measure('flow-layout-time', 'flow-layout-start', 'flow-layout-end');
  const flowItemPositionTime = performance.measure('flow-item-position-time', 'flow-layout-start', 'flow-items-positioned');
  const flowConnectorsTime = performance.measure('flow-connectors-time', 'flow-connectors-start', 'flow-connectors-end');
  const flowConnectorAdjustmentsTime = performance.measure('flow-connector-adjust-time', 'flow-connector-adjustments-start', 'flow-connector-adjustments-end');
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

   view.pageAdditionDialog = new DialogForm($dialog, {
    autoOpen: $errors.length ? true : false,
    onClose: function() {
      $errors.parents().removeClass('error');
      $errors.remove(); // Remove from DOM (includes removing all jQuery data)
      $dialog.find('.govuk-form-group').removeClass('govuk-form-group--error');
      utilities.updateHiddenInputOnForm($form, "page[page_type]", "");
      utilities.updateHiddenInputOnForm($form, "page[component_type]", "");
      utilities.updateHiddenInputOnForm($form, "page[conditional_uuid]", "");
    }
  })
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the context menus for each flow item within an overview layout.
 **/
function createPageMenus(view) {
  $("[data-component='ItemActionMenu']").each((_, el) => {
    new PageMenu($(el), {
      view: view,
      preventDefault: true, // Stops the default action of triggering element.
      menu: {
        position: {
          my: "left top",
          at: "left top",
        }
      }
    });
  });
}
/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the connection menus for each flow item within an overview layout.
 **/
function createConnectionMenus(view) {
  $("[data-component='ConnectionMenu']").each((_, el) => {
    new ConnectionMenu($(el), {
      view: view,
      preventDefault: true, // Stops the default action of triggering element.
      menu: {
        position: {
          my: "left top",
          at: "left top",
        }
      }
    });
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
  performance.mark('flow-layout-start');
  createAndPositionFlowItems(view, $container);
  performance.mark('flow-items-positioned');
  adjustOverviewHeight($container);
  performance.mark('flow-connectors-start');
  applyPageFlowConnectorPaths(view, $container);
  applyBranchFlowConnectorPaths(view, $container);
  applyRouteEndFlowConnectorPaths(view, $container);
  performance.mark('flow-connectors-end');
  performance.mark('flow-connector-adjustments-start');
  adjustOverlappingFlowConnectorPaths($container);
  performance.mark('flow-connector-adjustments-end');
  adjustBranchConditionPositions($container);
  adjustOverviewHeight($container);
  adjustOverviewWidth($container);
  performance.mark('flow-layout-end')
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
function layoutDetachedItemsOverview(view) {
  var $container = view.$flowDetached;
  var expander = $container.find('.Expander').data("instance"); // Element is set as an Expander Component.

  // Make sure it's open on page load
  expander.open();

  // Add required scrolling to layout groups.
  $(SELECTOR_FLOW_DETACHED_GROUP, $container).each(function() {
    var $group = $(this);
    createAndPositionFlowItems(view, $group);
    adjustOverviewHeight($group);
    applyPageFlowConnectorPaths(view, $group);
    applyBranchFlowConnectorPaths(view, $group);
    adjustOverlappingFlowConnectorPaths($group);
    adjustBranchConditionPositions($group);
    adjustOverviewHeight($group);
    adjustOverviewWidth($group);
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Main function to find and position flow items (pages/branches/spacers)
 * within an overview layout.
**/
function createAndPositionFlowItems(view, $overview) {
  var $columns = $(".column", $overview);
  var rowHeight = view.page.flowItemsRowHeight;
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
        id: $item.attr("data-fb-id"),
        next: $item.attr("data-next"),
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
          $fromm: $condition.attr("data-from"),
          $next: $condition.attr("data-next"),
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
  $overview.find(".flow-expressions").each(function() {
    var $this = $(this);
    var expressionHeight = Number($this.height()) || 0;
    $this.css({
      position: "relative",
      top: "-" + (expressionHeight + (lineHeight * 2) ) + "px"
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

  $items.each(function() {
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
    $overview.css("margin-top", topOverlap + "px");
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
 * To try and fix scrolling issues for the ServicresEdit page
 * when flow overview areas extend beyond the restricted width
 * of the main content area.
 * @view (Object) Reference to the overall view instance of Services#edit action.
 *
 * Note: Way too much CSS manipulation here but we're trying to deal with dynamic
 * situations that cannot really be done (easily/at all??) with a stylesheet.
 **/
function addServicesContentScrollContainer(view) {
  var $container = $("<div id=\"ServicesContentScrollContainer\"></div>");
  var $html = $("html");
  var $body = $("body");
  var $main = $("#main-content");
  var $title = $(".flow-titlebar");
  var $header = $("header");
  var $nav = $("#form-navigation");
  var $footer = $("footer");
  var $footerContent = $footer.find(".govuk-width-container"); // Terrible lookup but we're dealing with GDS class names
  var timeout;

  // Make adjustments to layout elements.
  view.$flowOverview.before($container);
  $container.append(view.$flowOverview);
  $container.append(view.$flowDetached);
  $container.append(view.$flowStandalone);

  // Would prefer this in stylesheet but doing it here to detect and copy
  // any GDS dynamic values in use or quickly implement only when the
  // scrollable area is in play (without doing element detaction and css
  // class variants, etc.
  // Removing the <html> (grey) background that was for the footer.
  // And overriding GDS set margin-bottom that exposes <html> area.
  $html.css("background-color", "white");
  $body.css("margin-bottom", "0px");
  $footer.css("position", "relative");

  // Make adjustments based on content.
  adjustScrollDimensionsAndPositions($body, $container, $main, $header, $nav, $title, $footer, $footerContent);

  // So the dimension self-correct upon browser resizing (or tablet rotate).
  $(window).on("resize", function() {

    // Hide the content before recalculation
    $main.removeClass(view.constants.JS_ENHANCEMENT_DONE);

    // Delay and timeout is to wait for user to stop moving things (reduces attempts to update view).
    clearTimeout(timeout);
    timeout = setTimeout(function() {

      // Reset everything
      window.scrollTo(0,0);
      $header.get(0).style = "";
      $nav.get(0).style = "";
      $title.get(0).style = "";
      $footer.get(0).style = "";
      $footerContent.get(0).style = "";

      adjustScrollDimensionsAndPositions($body, $container, $main, $header, $nav, $title, $footer, $footerContent);

      // Finished so reveal updated content
      $main.addClass(view.constants.JS_ENHANCEMENT_DONE);
    }, 750);
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Sort out the required dimensions and position for the scrollable area.
 * @$container (jQuery node) The dynamically added container applied to main scrollable content.
 **/
function adjustScrollDimensionsAndPositions($body, $container, $main, $header, $nav, $title, $footer, $footerContent) {
  var viewWidth = window.innerWidth;
  var mainLeft = $main.offset().left;
  var headerTop = $header.position().top;
  var navTop = $nav.position().top;
  var titleTop = $title.offset().top;
  var containerTop = titleTop + $title.outerHeight();
  var containerWidth = mainLeft + $container.get(0).scrollWidth;

  // Remove any existing event if calling for second time.
  $(document).off("scroll.adjustScrollDimensionsAndPosition");

  // Fix/update the position of some elements (the order is important).
  $title.css({
    left: mainLeft + "px",
    right: mainLeft + "px",
    position: "fixed",
    top: titleTop + "px"
  });

  $nav.css({
    "border-bottom": "110px solid white",
    position: "fixed",
    top: navTop + "px",
    width: "100%"
  });

  $header.css({
    position: "fixed",
    top: headerTop + "px",
    width: "100%"
  });

  // If scroll is not enough we need to stretch the footer horizontally.
  if(containerWidth > viewWidth) {
    $footer.css("width", containerWidth + "px");
  }
  else {
    $footer.css("width", viewWidth + "px");
  }

  // If content length is not enought we need to stretch the footer vertically.
  if($body.outerHeight() < window.innerHeight) {
    $footer.height($footer.height() + (window.innerHeight - $body.outerHeight()));
  }

  // Make sure the content aligns to left as thought centred to viewport not full width of scroll.
  $footerContent.css({
    "margin-left": mainLeft + "px",
    "max-width": $main.width() + "px"
  });

  // Now adjust the scroll container.
  $container.css({
    "margin-top": containerTop + "px", // This one because we fixed elements above.
    "padding-left": mainLeft + "px",
    left: ~(mainLeft - 2) + "px",
    width: (viewWidth - 6) + "px"
  });

  // Need the header (and others) to stay put horizontally but not vertically.
  $(document).on("scroll.adjustScrollDimensionsAndPosition", function() {
    var y = ~window.scrollY;
    $header.css("top", (y) + "px");
    $nav.css("top", (y + navTop) + "px");
    $title.css("top", (y + titleTop) + "px");
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Function to apply the arrows (visual conntectors) that indicate the paths
 * between page objects within a flow.
 *
 * Note: Due to Branches working a little differently in terms of arrow
 * design, they are excluded from this function and put in one of their own.
 **/
function applyPageFlowConnectorPaths(view, $overview) {
  var $items = $overview.find('.flow-page[data-next]:not([data-next="trailing-route"])');
  var rowHeight = view.page.flowItemsRowHeight;

  $items.each(function() {
    var $item = $(this);
    var next = $item.data("next");
    var fromX = $item.position().left + $item.outerWidth() + 1; // + 1 for design spacing
    var fromY = $item.position().top + (rowHeight / 4);
    var $next = $("[data-fb-id=" + next + "]", $overview);


    try {
      var toX = $next.position().left - 1; // - 1 for design spacing
      var toY = $next.position().top + (rowHeight / 4);
    } catch(err) {
      view.sentry.send(err);
    }

    if( fromX && fromY && toX && toY) {
      calculateAndCreatePageFlowConnectorPath({
        from_x: fromX,
        from_y: fromY,
        to_x: toX,
        to_y: toY,
        via_x: COLUMN_SPACING - 20 // 20 because we don't want lines to start at edge of column space
      }, {
        from: $item.data("instance"),
        to: $next.data("instance"),
        container: $overview,
        top: 0,                     // TODO: Is this and the height below the best way to position
        bottom: $overview.height()  //       backward and skip forward lines to the boundaries?
      });
    }
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
function applyBranchFlowConnectorPaths(view, $overview) {
  var rowHeight = view.page.flowItemsRowHeight;
  var $flowItemElements = $overview.find(SELECTOR_FLOW_ITEM);

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
      var conditionX = $condition.outerWidth(true) - 25; // 25 because we don't want lines to start at edge of column space
      var conditionY = $branch.position().top + $condition.position().top;
      var halfBranchNodeWidth = (branchWidth / 2);
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
        // If on the same row but destination behind the current condition
        if(firstConditionItem) {
          new ConnectorPath.ForwardDownBackwardUpPath({
            from_x: branchX,
            from_y: branchY - (rowHeight / 4),
            to_x: destinationX,
            to_y: destinationY,
            via_x: conditionX,
            via_y: conditionY
          }, config);
        }
        else {
          new ConnectorPath.DownForwardDownBackwardUpPath({
            from_x: branchX - (branchWidth / 2),
            from_y: branchY,
            to_x: destinationX,
            to_y: destinationY,
            via_x: conditionX + halfBranchNodeWidth,
            via_y: conditionY
          }, config);
        }
      }
      else {
        // FORWARD
        if(firstConditionItem) {
          // FIRST CONDITION ITEM
          if(sameRow) {
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
            if(up) {
              new ConnectorPath.ForwardUpForwardDownPath({
                from_x: branchX,
                from_y: branchY - (rowHeight / 4),
                to_x: destinationX,
                to_y: destinationY,
                via_x: conditionX,
                via_y: conditionY
              }, config);
            }
            else {
              new ConnectorPath.ForwardDownForwardPath({
                from_x: branchX,
                from_y: branchY - (rowHeight / 4),
                to_x: destinationX,
                to_y: destinationY,
                via_x: conditionX,
                via_y: conditionY
              }, config);
            }
          }
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
                  via_x: conditionX + halfBranchNodeWidth,
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
                  via_x: conditionX + halfBranchNodeWidth,
                  via_y: conditionY
                }, config);
              }
            }
            else {
              // DOWN
              if(nextColumn) {
                new ConnectorPath.DownForwardDownForwardPath({
                  from_x: branchX - (branchWidth / 2),
                  from_y: branchY,
                  to_x: destinationX,
                  to_y: destinationY,
                  via_x: conditionX + halfBranchNodeWidth,
                  via_y: conditionY
                }, config);
              }
              else {
                new ConnectorPath.DownForwardUpForwardDownPath({
                  from_x: branchX - (branchWidth / 2),
                  from_y: branchY,
                  to_x: destinationX,
                  to_y: destinationY,
                  via_x: conditionX + halfBranchNodeWidth,
                  via_y: conditionY
                }, config);
              }
            }
          }
        }
      }
    });
  });
}

function applyRouteEndFlowConnectorPaths(view, $overview) {
  var $items = $overview.find('.flow-page[data-next="trailing-route"]');
  var rowHeight = view.page.flowItemsRowHeight;

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
  const recursionLimit = 150; // This is a safety feature for the while loop.
  var $paths = $overview.find(".FlowConnectorPath").not(".ForwardPath, .DownForwardPath"); // Filter out Paths we can ignore to save some processing time
  var somethingMoved;
  var numberOfPaths = $paths.length;
  var keepChecking = $paths.length > 1;
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
        if(path.prop('id') != current.prop('id')) {
          // If the paths intersect / overlap
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
          new ConnectorPath.ForwardUpForwardPath(points, config);
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
      new ConnectorPath.ForwardDownBackwardUpPath(points, config);
    }
  }
}

/* Standard search and convert for any elements that have an expander
 * data-component attribute to make it easier to apply the effect
 * using only the template and avoid having to interact with JavaScript.
 */
function createExpanderComponents() {
  $("[data-component=Expander]").each(function() {
    var $node = $(this);
    new Expander($node, {
      activator_source: $node.find('> h2').first(),
      wrap_content: true,
    });
  });
}



module.exports = ServicesController;
