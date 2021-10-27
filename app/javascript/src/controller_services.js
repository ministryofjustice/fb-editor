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
const DialogConfirmation = require('./component_dialog_confirmation');
const DefaultController = require('./controller_default');


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

  createPageAdditionDialog(view);
  createPageAdditionMenu(view);
  createFlowItemMenus(view);
  fixAddPageButtonPosition();

  layoutFormFlowOverview();
  layoutDetachedItemsOveriew();

  addTemporaryLayoutTestAbility(view);
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
    var view = this._config.view;

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
    var view = this._config.view;
    var $link = element.find("> a");
    var dialog = new DialogApiRequest($link.attr("href"), {
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


/* VIEW SPECIFIC COMPONENT:
 * ------------------------
 *
 * TODO: This will definitely need some extra work when it
 * comes to implementing more complex paths. Currently, this
 * has been created to support straight line connectors only.
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
    var $element = $("<div><span></span></div>");
    $element.addClass("FlowConnectorPath");
    $element.attr("data-from", config.from);
    $element.attr("data-to", config.to);
    $element.css({
      height: "0px",
      left: points.lX + "px",
      position: "absolute",
      top: points.lY + "px",
      width: FlowConnectorPath.difference(points.lX, points.rX) + "px"
    });

    // Now add it to the parent/containe
    if(config.$container && config.$container.length) {
      config.$container.append($element);
    }
    else {
      $(document.body).append($element);
    }
  }
}

// Get the difference between two numbers
FlowConnectorPath.difference = function(a, b) {
  if(a > b)
    return a - b;
  else
    return b - a;
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
function layoutFormFlowOverview() {
  var $overview = $("#flow-overview");
  positionFlowItems($overview);
  positionConditionsByDestination($overview);
  adjustOverviewHeight($overview);
  applyArrowPaths($overview);
  applyOverviewScroll($overview);
  //applyOverviewScrollListener($overflow);
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Create the detatched overview layout to get the required design.
**/
function layoutDetachedItemsOveriew() {
  $(".flow-detached-group").each(function() {
    var $overview = $(this);
    positionFlowItems($overview);
    positionConditionsByDestination($overview);
    adjustOverviewHeight($overview);
    applyOverviewScroll($overview);
  });
}


/* VIEW SETUP FUNCTION:
 * --------------------
 * Main function to find and position flow items (pages/branches/spacers)
 * within an overview layout.
**/
function positionFlowItems($overview) {
  const SELECTOR_FLOW_BRANCH = ".flow-branch";
  const SELECTOR_FLOW_CONDITIONS = ".flow-conditions";
  const SELECTOR_FLOW_CONDITION = ".flow-condition";
  const SELECTOR_FLOW_EXPRESSIONS = ".flow-expression";
  const SELECTOR_FLOW_THUMBNAIL = ".flow-thumbnail";
  const SELECTOR_FLOW_ITEM = ".flow-item";
  const THUMBNAIL_HEIGHT = $(SELECTOR_FLOW_ITEM).eq(0).height();
  const THUMBNAIL_WIDTH = $(SELECTOR_FLOW_THUMBNAIL).eq(0).outerWidth();
  const SPACING_X = 100;
  const SPACING_Y = THUMBNAIL_HEIGHT / 2;
  const CONDITIONS_LEFT_SPACING = $(SELECTOR_FLOW_BRANCH).outerWidth();
  var $columns = $(".column", $overview);
  var left = 0;

  // Loop over found columns created from the flow
  $columns.each(function(index) {
    var $column = $(this);
    var $conditions = $(SELECTOR_FLOW_CONDITIONS, this);
    var $expressions = $(SELECTOR_FLOW_EXPRESSIONS, $conditions);
    var $items = $(SELECTOR_FLOW_ITEM, this);
    var maxExpressionWidth = utilities.maxWidth($expressions);
    var top = 0;

    $items.each(function() {
      var conditionY = THUMBNAIL_HEIGHT / 2;
      var $item = $(this);

      // First, bring it out of the column because we don't need it.
      // We will remove the columns later.
      $column.before($item);

      // Positions boxes and diamonds
      $item.css({
        left: left + "px",
        position: "absolute",
        top: top + "px"
      });

      // Positions bubbles
      $(SELECTOR_FLOW_CONDITION, this).each(function() {
        var $condition = $(this);
        $condition.css({
          left: 0,
          position: "absolute",
          bottom: ($condition.height() - conditionY) + "px"
        });

        conditionY += THUMBNAIL_HEIGHT + SPACING_Y;
      });

      top += THUMBNAIL_HEIGHT + SPACING_Y; // TODO: This might need some thinking to line things up.
    });

    if($conditions.length > 0) {
      // Positions bubble container relative to diamond.
      $conditions.css({
        left: CONDITIONS_LEFT_SPACING + "px",
        position: "absolute",
        top: "0px"
      });

      // Adjust distance based on finding some conditions
      left += ($conditions.width() + SPACING_X);
    }
    else {
      // Adjust distance based just on column width
      left += utilities.maxWidth($items);
    }

    left += SPACING_X; // Use same spacing regardless of condition found, or not.
  });

  // Ditch the columns.
  $columns.remove();
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * After initial positionFlowItems() method has finished, we need to revisit
 * the Conditional text items to try and align them better with their actual
 * destination items. To ignore this step can result in condition items
 * aligning with an incorrect row or even, being placed on an entirely new
 * and unpopulated row.
 *
 * Note 1: initial problem was highlighted by a 3-row layout that had a branch
 * on the 2nd row, with three conditions showing, each one on a separate row.
 * The first lined up with the branch node, and the others followed beneath.
 * This meant, the first condition, which had a destination page sitting on
 * the row above, essentially positioned all three Condition text elements
 * exactly one row beneath a more correct row position.)
 *
 * Note 2: have adjusted to ignore 'Otherwise' expression which can end up on
 * the top row in some configurations (e.g. Just points to CYA page), which
 * means it sits incorrectly flow of what would be the top path.
 **/
function positionConditionsByDestination($overview) {
  const SELECTOR_FLOW_BRANCH = ".flow-branch";
  const SELECTOR_FLOW_CONDITION = ".flow-condition";

  $overview.find(SELECTOR_FLOW_CONDITION).each(function() {
    var $node = $(this);
    var $parent = $node.parents(SELECTOR_FLOW_BRANCH);
    var parentTop = $parent.position().top;
    var next = $node.data("next");
    var $destination = $overview.find("#" + next);
    var destinationTop = $destination.length ? $destination.position().top : -1; // Didn't find a destination ??

    if(destinationTop >= 0 && $node.data("otherwise") == "false") {
      $node.css("bottom", parentTop - (destinationTop + ($destination.height() / 2)) + "px");
    }
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
  var $items = $(".flow-item", $overview);
  var lowestPoint = 0;

  $items.each(function() {
    var $current = $(this);
    var height = $current.css("height", "auto").outerHeight(true); // 1. Eliminate CSS height to get better calculation.
    var bottom = $current.position().top + height;

    $current.css("height", ""); // 2. Reset inline so CSS height is back in play.

    if(bottom > lowestPoint) {
      lowestPoint = bottom;
    }
  });

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
  var overviewWidth = $overview.width();
  var containerWidth;

  $container.addClass("FlowOverviewScrollingFrame");
  $overview.append($container);
  $container.append($children);
  containerWidth = $container.get(0).scrollWidth;

  if(containerWidth > overviewWidth) {
    let offsetLeft = $overview.offset().left;
    let margin = 30; // Arbitrary number based on common
    let maxWidth = window.innerWidth - (margin * 2);
    let left = (containerWidth - overviewWidth) / 2;
    if(left < offsetLeft) {
      $container.css("left", ~left);
    }
    else {
      $container.css("left", ~(offsetLeft - margin));
    }

    $container.css("width", maxWidth + "px");
  }
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * For form overview scrolling and reactivation on resize.
 **/
function applyOverviewScrollListener($overflow) {
// TODO: UPDATE THIS FOR NEW VIEW
return;
  applyCustomOverviewWorkaround();
  let scrollTimeout;
  $(window).on("resize", function() {
    scrollTimeout = setTimeout(function() {
      clearTimeout(scrollTimeout);
      applyCustomOverviewWorkaround();
    }, 500);
  });
}


/* VIEW HELPER FUNCTION:
 * ---------------------
 * Function to apply the arrows (visual conntectors) that indicate the paths
 * between page and branch objects within a flow.
 *
 * Note: This is an initial WIP effort designed to replicate the old view
 * arrows on a linear-only, non-branching, view, where straight arrows only
 * are supported. The old view used CSS to achieve that but this function is
 * intended to provide the basis for the far more complex arrow layout
 * required for a full branching view.
 **/
function applyArrowPaths($overview) {
  // Note: flow-condition element do not currently work with this.
  $overview.find("[data-next]").not(".flow-condition").each(function() {
    var $this = $(this);
    var next = $this.data("next");
    var fromX = $this.position().left + $this.outerWidth() + 1; // + 1 for design spacing
    var fromY = $this.position().top + ($this.height() / 2);
    var $next = $("#" + next);
    var toX = $next.position().left - 1; // - 1 for design spacing
    var toY = $next.position().top + ($next.height() / 2);

    new FlowConnectorPath({
      lX: fromX,
      lY: fromY,
      rX: toX,
      rY: toY
      }, {
      $container: $overview,
      from: $this.attr("id"),
      to: next,
      space: 5
    });
  });
}


/* TEMPORARY FIX
 * -------------
 * For form overview Add Page button location.
 * Due to changes required for the updated Flow Overview
 * layout, the Add Page menu HTML has been relocated outside
 * of the original DIV.form-overview element. This move has
 * affected the location of the dynamically inserted menu
 * activator and resulting CSS positioning. To correct this
 * the function here moves the element back to the original
 * location, leaving the menu in it's new position.
 **/
function fixAddPageButtonPosition() {
  $("#form-overview").append($(".form-overview-button"));
}


/*
 * -----------------------------------------------------------------------------
 * DEVELOPMENT ONLY
 * -----------------------------------------------------------------------------
 */
function addTemporaryLayoutTestAbility(view) {
  var $template = $("[data-component-template=DialogConfirmation]");
  var $node = $($template.text());
  var $button = $("<button>Upload json</button>");
  var $textarea = $("<textarea style=\"margin-bottom:20px; width:100%\" rows=\"25\"></textarea>");
  var dialog;

  $node.append($textarea);
  $button.on("click", function() {
    dialog.open({
      heading: "Create a layout from JSON",
      content: "Paste some JSON format text here and press 'ok' to generate a deletable temporary layout view for testing."
    });
  });

  view.$body.append($button);
  view.$body.append($node);
  dialog = new DialogConfirmation($node, {
    onOk: function() {
      var text = $textarea.val();
      var json = JSON.parse(text);
      var diamond = view.$body.html().match(/\/packs\/media\/images\/diamond-\w+?.svg/);
      var src = (diamond.length ? diamond[0] : "diamond.svg"); // What to do if does not exist??
      var $delete = $("<button>Delete</button>");
      var $container = $("<div></div>");

      $container.attr("id", utilities.uniqueString("temporary-layout-"));
      $container.css({
        border: "1px solid grey",
        margin: "20px",
        height: "500px",
        overflow: "auto",
        padding: "40px",
        position: "relative"
      });

      $delete.css({
        bottom: "0px",
        left: "0p;x",
        position: "absolute",
      });

      $delete.on("click", function() {
        $container.empty();
        $container.remove();
      });

      let index = 0;
      for(var col in json) {
        let collection = json[col];
        let $column = $("<div class=\"column\"></div>");

        for(var it in collection) {
          let item = collection[it];

          if(item.type == "spacer") {
            let $section = $("<section class=\"flow-item flow-spacer\"></section>");
            $column.append($section);
          }
          else {
            if(item.type == "flow.branch") {
              let $section = $("<section class=\"flow-item flow-branch\"></section>");
              $section.append("<img src=\"" + src + "\" />");
              $section.append("<a class=\"govuk-link\"><span class=\"text\">" + item.title + "</span></a>");

              let $ul = $("<ul class=\"flow-conditions\"></ul>");
              for(var con in item.conditionals) {
                let condition = item.conditionals[con];
                let $li = $("<li class=\"flow-condition\" data-fb-next=\"" + item.next + "\"></li>");

                for(var ex in condition.expressions) {
                  let expression = condition.expressions[ex];
                  $li.append("<div class=\"flow-expression\"> \
                                <span class=\"question\">" + expression.question + "</span> \
                                <span class=\"operator\">" + expression.operator + "</span> \
                                <span class=\"answer\">" + expression.answer + "</span> \
                              </div>");
                }
                $ul.append($li);
              }

              $section.append($ul);
              $column.append($section);
            }
            else {
              let $section = $("<section class=\"flow-item flow-page\"></section>");
              $section.append("<a class=\"flow-thumbnail text\"><span class=\"text\">" + item.title + "</span></a>");
              $section.append("<a class=\"govuk-link\" href=\"#\"><span class=\"text\">" + item.title.replace(/\s/g, "") + "</span></a>");
              $column.append($section);
            }
          }
        }

        $container.append($column);
      }

      view.$body.append($container);
      positionFlowItems($container);
      $container.append($delete);
      $textarea.val("");
    },
    onCancel: function() {
      $textarea.val("");
    }
  });

}





module.exports = ServicesController;
