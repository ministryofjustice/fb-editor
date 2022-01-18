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
const mergeObjects = utilities.mergeObjects;
const post = utilities.post;
const ActivatedMenu = require('./component_activated_menu');
const DialogApiRequest = require('./component_dialog_api_request');
const DefaultController = require('./controller_default');
const ConnectorPath = require('./component_flow_connector_path');

const COLUMN_SPACING = 100;
const SELECTOR_FLOW_BRANCH = ".flow-branch";
const SELECTOR_FLOW_CONDITION = ".flow-condition";
const SELECTOR_FLOW_ITEM = ".flow-item";


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
  createPageAdditionMenu(view);
  createFlowItemMenus(view);

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

    this.$node = $node;
    this.id = $node.attr("id");
    this.next = $node.attr("next");
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
 * Control form step (add/edit/delete/preview...) menus
 **/
class FlowItemMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      activator_classname: $node.data("activator-classname"),
      container_id: $node.data("activated-menu-container-id"),
      activator_text: $node.data("activator-text")
    }, config));

    $node.on("menuselect", (event, ui) => {
      this.selection(event, ui.item);
    });

    this.activator.$node.addClass("FlowItemMenuActivator");
    this.container.$node.addClass("FlowItemMenu");
    this.uuid = $node.data("uuid");
    this.title = $node.data("title");
  }

   // Handle item selections on the form step context menu elements.
  selection(event, item) {
    var action = item.data("action");

    event.preventDefault();
    switch(action) {
      case "preview":
           this.previewPage(item);
           break;

      case "add":
           this.addPage(item);
           break;

      case "destination":
           this.changeDestination(item);
           break;

      case "delete":
           this.deleteItem(item);
           break;

      case "delete-api":
           this.deleteItemApi(item);
           break;

      default: this.link(item);
    }
  }

  link(element) {
    var $link = element.find("> a");
    location.href = $link.attr("href");
  }

  previewPage(element) {
    var $link = element.find("> a");
    window.open($link.attr("href"));
  }

  // Open the views Page Addition Menu
  addPage(element) {
    var menu = this._config.view.pageAdditionMenu;
    menu.addPageAfter = this.uuid;
    menu.open({
      my: "left top",
      at: "right top",
      of: element
    });
  }

  // Open an API request dialog to change destination
  changeDestination(element) {
    var view = this._config.view;
    var $link = element.find("> a");
    new DialogApiRequest($link.attr("href"), {
      activator: $link,
      buttons: [{
        text: view.text.dialogs.button_change_destination,
        click: function(dialog) {
          dialog.$node.find("form").submit();
        }
      }, {
        text: view.text.dialogs.button_cancel
      }]
    });
  }

  // Use standard delete modal to remove
  deleteItem(element) {
    var view = this._config.view;
    var $link = element.find("> a");
    view.dialogConfirmationDelete.open({
      heading: view.text.dialogs.heading_delete.replace(/%{label}/, this.title),
      ok: view.text.dialogs.button_delete_page
      }, function() {
        post($link.attr("href"), { _method: "delete" });
    });
  }

  deleteItemApi(element) {
    var $link = element.find("> a");
    new DialogApiRequest($link.attr("href"), {
      activator: $link,
      closeOnClickSelector: ".govuk-button",
      build: function(dialog) {
        // Find and correct (make work!) any method:delete links
        dialog.$node.find("[data-method=delete]").on("click", function(e) {
          e.preventDefault();
          utilities.post(this.href, { _method: "delete" });
        });
      }
    });
  }
}

/* VIEW SPECIFIC COMPONENT:
 * ------------------------
 * Controls form step Add page functionality
 **/
class PageAdditionMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      activator_classname: $node.data("activator-classname"),
      container_id: $node.data("activated-menu-container-id"),
      activator_text: $node.data("activator-text")
    }, config));

    this.container.$node.addClass("PageAdditionMenu");

    // Register event handler for selection of menu item.
    $node.on("menuselect", (event, ui) => {
      this.selection(event, ui.item);
    });
  }

  set addPageAfter(uuid) {
    this._uuid = uuid;
  }

  get addPageAfter() {
    return this._uuid;
  }

  selection(event, item) {
    var dialog = this._config.view.pageAdditionDialog;
    var $form = dialog.$form;

    // Set the 'add_page_here' value to mark point of new page inclusion.
    // Should be a uuid of previous page or blank if at end of form.
    utilities.updateHiddenInputOnForm($form, "page[add_page_after]", this.addPageAfter);

    // Then add any required values.
    utilities.updateHiddenInputOnForm($form, "page[page_type]", item.data("page-type"));
    utilities.updateHiddenInputOnForm($form, "page[component_type]", item.data("component-type"));

    this._config.view.pageAdditionDialog.open();
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
 * Create the menu effect and required functionality for controlling and selecting new page types.
 **/
function createPageAdditionMenu(view) {
  var $menu = $("[data-component='PageAdditionMenu']"); // Expect only one

  view.pageAdditionMenu = new PageAdditionMenu($menu, {
    view: view,
    selection_event: "PageAdditionMenuSelection",
    menu: {
      position: { at: "right+2 top-2" } // Position second-level menu in relation to first.
    }
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the context menus for each flow item within an overview layout.
 **/
function createFlowItemMenus(view) {
  $("[data-component='ItemActionMenu']").each((i, el) => {
    var menu = new FlowItemMenu($(el), {
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
**/
function layoutFormFlowOverview(view) {
  var $container = view.$flowOverview;
  positionFlowItems($container);

  // TEMPORARY: BRANCHING FEATURE FLAG
  if(!view.features.branching) {
    positionAddPageButton();
  }

  adjustOverviewHeight($container);
  applyPageFlowConnectorPaths($container);
  applyBranchFlowConnectorPaths($container);
  adjustOverlappingFlowConnectorPaths($container);
  adjustBranchConditionPositions($container);
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
**/
function layoutDetachedItemsOveriew(view) {
  var $container = view.$flowDetached;
  var $title = $("h2", $container);
  var offsetLeft = $container.offset().left;

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
    var $expander = $(".Expander_container");
    var display = $expander.css("display");
    $expander.css("display", "block"); // display:none objects have no height in jQuery

    positionFlowItems($group);
    adjustOverviewHeight($group);
    applyPageFlowConnectorPaths($group);
    applyBranchFlowConnectorPaths($group);
    adjustOverlappingFlowConnectorPaths($group);
    adjustBranchConditionPositions($group);
    applyOverviewScroll($group);

    $expander.css("display", display); // Reset to original state
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Main function to find and position flow items (pages/branches/spacers)
 * within an overview layout.
**/
function positionFlowItems($overview) {
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
        y: top + (rowHeight / 4)
      });

      // Set column and row information for items.
      $item.attr("column", column);
      $item.attr("row", row);

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

        // Set column and row information for items.
        $condition.attr("column", column);
        $condition.attr("row",  row + index); // Add row because Branch row is not always zero.

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
  var $items = $(SELECTOR_FLOW_ITEM, $overview);
  var lowestPoint = 0;

  $items.each(function() {
    var $item = $(this);
    var itemTop = $item.position().top;
    var bottom = itemTop + $item.outerHeight(true);

    // Flow items will include the branch but not the conditions so we need to
    // assess them separately. Because the zero-point for a condition is the
    // top of a branch, the baseline needs to include that count as part of the
    // calculation.
    if($item.hasClass("flow-branch")) {
      let $conditions = $item.find(SELECTOR_FLOW_CONDITION);
      let top = $conditions.first().position().top;
      let baseline = itemTop + $conditions.last().position().top + $conditions.last().outerHeight(true);
      if(top < 0) {
        top = ~(top); // Turn something like -14.5 into 14.5
      }

      bottom = (top + baseline);
    }

    if(bottom > lowestPoint) {
      lowestPoint = bottom;
    }
  });

  // DEV TODO: Need to figure out top boundary after this disabling.
  $overview.css("height", lowestPoint + "px");
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * To try and fix scrolling issues for the form overview
 * when there are too many thumbnails to fix on the one page view.
 **/
function applyOverviewScroll($overview) {
  var $container = $("<div></div>");
  var $children = $overview.children();
  var scrollTimeout;

  $container.addClass("FlowOverviewScrollingFrame");
  $container.height($overview.height()); // first steal the height from overview then reset
  $overview.height("auto");              // the overview so it is controlled by container.

  $overview.append($container);
  $container.append($children);

  // Apply initial adjustment.
  adjustOverviewScrollDimensions($overview, $container);

  // Listen for screen changes to reapply.
  $(window).on("resize", function() {
    scrollTimeout = setTimeout(function() {
      clearTimeout(scrollTimeout);
      adjustOverviewScrollDimensions($overview, $container);
    }, 500);
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Heart of the solution for applyOverviewScroll() that tries to
 * sort out the required dimensions for the layout area.
 **/
function adjustOverviewScrollDimensions($overview, $container) {
  var overviewWidth = $overview.width()
  var overviewTop = $overview.offset().top;
  var containerWidth = $container.get(0).scrollWidth;
  var margin = 30; // Arbitrary number based on common
  var viewWidth = window.innerWidth - (margin * 2);
  var top;

  // Sort out widths...
  if(containerWidth > overviewWidth) {
    let offsetLeft = $overview.offset().left;
    let left = (containerWidth - overviewWidth) / 2;

    if(left < offsetLeft) {
      $overview.css("left", ~(left - margin) + "px");
    }
    else {
      $overview.css("left", ~(offsetLeft - margin));
    }

    $overview.css("width", viewWidth + "px");
  }

  // Sort out heights...
  $(".FlowConnectorPath path:first-child", $overview).each(function() {
    var $this = $(this);
    var offsetTop = $this.offset().top;
    if(!top || top > offsetTop) {
      top = offsetTop;
    }
  });

  if(top < overviewTop) {
    $overview.css("padding-top", (overviewTop - top) + "px");
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
  var $items = $overview.find(".flow-page[data-next]");
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
      from: $item,
      to: $next,
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
  var $itemsByRow = $overview.find("[row]");
  var rowHeight = utilities.maxHeight($itemsByRow);

  $overview.find(SELECTOR_FLOW_BRANCH).each(function() {
    var $branch = $(this);
    var branchX = $branch.position().left + $branch.outerWidth() + 1; // + 1 for design gap
    var branchY = $branch.position().top + (rowHeight / 4);
    var branchWidth = $branch.outerWidth();
    var $conditions = $branch.find(SELECTOR_FLOW_CONDITION);

    $conditions.each(function(index) {
      var $condition = $(this);
      var $destination = $("[data-fb-id=" + $condition.data("next") + "]", $overview);

      // --------------------------------------------------------------------------------------------
      // TODO: Temporary hack to prevent missing destination item bug  breaking the layout
      // https://trello.com/c/iCDLMDgo/1836-bug-branchcondition-destination-page-is-in-detached-items
      if($destination.length < 1) return true;
      // --------------------------------------------------------------------------------------------

      var destinationX = $destination.position().left;
      var destinationY = $destination.position().top + (rowHeight / 4);
      var conditionX = (branchWidth / 2) + $condition.outerWidth(true) - 25 // 25 because we don't want lines to start at edge of column space
      var conditionY = $branch.position().top + $condition.position().top;
      var conditionColumn = Number($condition.attr("column"));
      var conditionRow = Number($condition.attr("row"));
      var destinationColumn = Number($destination.attr("column"));
      var destinationRow = Number($destination.attr("row"));
      var backward = conditionColumn > destinationColumn;
      var sameColumn = (conditionColumn == destinationColumn);
      var sameRow = (conditionRow == destinationRow);
      var firstConditionItem = (index == 0);
      var up = conditionRow > destinationRow;
      var nextColumn = (conditionColumn + 1 == destinationColumn);
      var config = {
            container: $overview,
            from: $branch,
            to: $destination,
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
            from_y: branchY,
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
  var keepChecking = true;
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
 * apply positionFlowItems() function to help determine the connector path type required.
 *
 * @points (Object) Properties for x/y coordinates (see FlowConnectorPath Class)
 * @config (Object) Various items/properties required by FlowConnectorPath Class.
 **/
function calculateAndCreatePageFlowConnectorPath(points, config) {
  var columnItem = Number(config.from.attr("column"));
  var columnNext = Number(config.to.attr("column"));
  var rowItem = Number(config.from.attr("row"));
  var rowNext = Number(config.to.attr("row"));
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
    }
    else {
      if(up) {
        new ConnectorPath.ForwardDownBackwardUpPath(points, config);
      }
    }
  }
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Handles position and setup of the Add Page button.
 **/
function positionAddPageButton() {
  var $overview = $("#flow-overview");
  var $button = $(".flow-add-page-button");
  var $items = $(SELECTOR_FLOW_ITEM, $overview).not("[data-next]"); // Expect only one.
  var rowHeight = utilities.maxHeight($items); // There's always a starting page.
  var id = utilities.uniqueString("add-page-");
  var $item;

  // Find last item on first row (again, we should only be dealing with one but just making sure).
  $items.each(function() {
    var $this = $(this);
    if($this.position().top == 0) {
      $item = $this;
      $item.attr("data-next", id);
    }
  });

  // Position button next to $item.
  $overview.append($button);
  $button.attr("data-fb-id", id);
  $button.css({
    display: "inline-block",
    left: Number($item.position().left + $item.outerWidth() + COLUMN_SPACING) + "px",
    position: "absolute",
    top: "43px"
  });

  // Add the FlowConnectorPath.
  new ConnectorPath.ForwardPath({
    from_x: $item.position().left + $item.outerWidth() + 1, // + 1 for design spacing,
    from_y: $item.position().top + (rowHeight / 4),
    to_x: $button.position().left - 1, // - 1 for design spacing,
    to_y: $item.position().top + (rowHeight / 4), // Should be a straight line only.
    via_x: COLUMN_SPACING - 20 // 25 because we don't want lines to start at edge of column space
    }, {
    from: $item,
    to: $button,
    container: $overview,
    top: 0,                     // TODO: Is this and the height below the best way to position
    bottom: $overview.height()  //       backward and skip forward lines to the boundaries?
  });
}

module.exports = ServicesController;
