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

  createPageAdditionDialog(view);
  createPageAdditionMenu(view);
  createFlowItemMenus(view);

  if(view.$flowOverview.length) {
    layoutFormFlowOverview(view);
  }

  if(view.$flowDetached.length) {
    layoutDetachedItemsOveriew(view);
  }

  addServicesContentScrollContainer(view);

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
  adjustOverlappingFlowConnectorPaths($container);
  adjustBranchConditionPositions($container);
  adjustOverviewHeight($container);
  adjustOverviewWidth($container);
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
  var expander = $container.data("instance"); // Element is set as an Expander Component.

  // Make sure it's open on page load
  expander.open();

  // Add required scrolling to layout groups.
  $(SELECTOR_FLOW_DETACHED_GROUP, $container).each(function() {
    var $group = $(this);
    createAndPositionFlowItems($group);
    adjustOverviewHeight($container);
    applyPageFlowConnectorPaths($group);
    applyBranchFlowConnectorPaths($group);
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

  $items.each(function() {
    var $item = $(this);
    var top = Math.ceil($item.offset().top);
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
    $overview.css("height", (bottom - top) + "px");
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
 **/
function addServicesContentScrollContainer(view) {
  var $container = $("<div id=\"ServicesContentScrollContainer\"></div>");
  var $html = $("html");
  var $body = $("body");
  var $main = $("#main-content");
  var $title = $("h1");
  var $button = $(".fb-preview-button");
  var $header = $("header");
  var $nav = $("#form-navigation");
  var $footer = $("footer");
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
  $footer.css("relative");

  // Make adjustments based on content.
  adjustScrollDimensionsAndPositions($container, $header, $nav, $title, $button);

  // So the dimension self-correct upon browser resizing (or tablet rotate).
  $(window).on("resize", function() {

    // Hide the content and reset things
    $main.css("visibility", "hidden");
    $header.get(0).style = "";
    $nav.get(0).style = "";
    $title.get(0).style = "";
    $button.get(0).style = "";

    // Delay and timeout is to wait for user to stop moving things (reduces attempts to update view).
    clearTimeout(timeout);
    timeout = setTimeout(function() {
      adjustScrollDimensionsAndPositions($container, $header, $nav, $title, $button);

     // Clear the view blocker because we're done shifting stuff.
     $main.css("visibility", "visible");
    }, 750);
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Sort out the required dimensions and position for the scrollable area.
 * @$container (jQuery node) The dynamically added container applied to main scrollable content.
 **/
function adjustScrollDimensionsAndPositions($container, $header, $nav, $title, $button) {
  var viewWidth = window.innerWidth;
  var $main = $("#main-content");
  var $footer = $("footer");
  var mainLeft = $main.offset().left;
  var headerTop = $header.position().top;
  var navTop = $nav.position().top;
  var titleTop = $title.offset().top;
  var buttonTop = $button.offset().top;
  var fixedHeight = titleTop + $title.outerHeight();

  // Remove any existing event if calling for second time.
  $(document).off("scroll.adjustScrollDimensionsAndPosition");

  // Reset the view position
  window.scrollTo(0,0);

  // Fix/update the position of some elements (the order is important).
  $button.css({
    left: (mainLeft + $main.width()) + "px",
    position: "fixed",
    top: $button.offset().top + "px"
  });

  $title.css({
    left: mainLeft + "px",
    position: "fixed",
    top: $title.offset().top + "px"
  });

  $nav.css({
    "border-bottom": "110px solid white",
    position: "fixed",
    top: $nav.offset().top + "px",
    width: "100%"
  });

  $header.css({
    position: "fixed",
    top: $header.offset().top + "px",
    width: "100%"
  });

  // Now adjust the scroll container.
  $container.css({
    "margin-top": fixedHeight + "px", // This one because we fixed elements above.
    "padding-left": mainLeft + "px",
    left: ~(mainLeft - 2) + "px",
    width: (viewWidth - 6) + "px"
  });

  // Need the header/footer (and others) to stay put horizontally but not vertically.
  $(document).on("scroll.adjustScrollDimensionsAndPosition", function() {
    var y = ~window.scrollY;
    $header.css("top", (y) + "px");
    $nav.css("top", (y + navTop) + "px");
    $title.css("top", (y + titleTop) + "px");
    $button.css("top", (y + buttonTop) + "px");
    $footer.css("left", window.scrollX + "px");
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
