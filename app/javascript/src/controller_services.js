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
const updateHiddenInputOnForm = utilities.updateHiddenInputOnForm;
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


/* Setup for the Edit action
 **/
ServicesController.edit = function() {
  var view = this; // Just making it easlier to understand the context.
  var $flowOverview = $("#flow-overview");
  var $pageCreateForm = $("#page-create-dialog");

  // Bind document event listeners to control functionality not specific to a single component or where
  // a component can be activated by more than one element (prevents complicated multiple element binding/handling).
  $(document).on("PageActionMenuSelection", pageActionMenuSelection.bind(view) );

  // Create dialog for handling new page input and error reporting.
  //view.pageCreateDialog = new PageCreateDialog(view, $("[data-component='PageCreateDialog']"));
  view.pageCreateDialog = new FormDialog($pageCreateForm, {
    cancelText: $pageCreateForm.attr("data-cancel-text"),
    selectorErrors: ".govuk-error-message",
    removeErrorClasses: ".govuk-form-group--error"
  });

  createMenusForThumbnails(view);
  createMenuForAddPage(view);
  fixAddPageButtonPosition();
  fixFormOverviewScroll();

  positionFlowItems($flowOverview);
  applyFlowOverviewWidthWorkaround($flowOverview);

  addTemporaryLayoutTestAbility(view);
}


/* Control form step (add/edit/delete/preview...) menus
 **/
class PageActionMenu extends ActivatedMenu {
  constructor($node, dialog, config) {
    super($node, mergeObjects({
      activator_classname: $node.data("activator-classname"),
      container_id: $node.data("activated-menu-container-id"),
      activator_text: $node.data("activator-text")
    }, config));

    this.uuid = $node.data("uuid");
    this.dialog = dialog;
  }
}


/* Handle item selections on the form step context
 * menu elements.
 **/
function pageActionMenuSelection(event, data) {
  var element = data.original.element;
  var action = data.activator.data("action");
  var view = this;

  switch(action) {
    case "preview":
         window.open(element.href);
         break;

    case "add":
         // Set the 'add_page_here' value in form.
         // This should be a uuid value if from thumbnail context menu, of
         // just set it to blank string if from the main 'Add page' button.
         updateHiddenInputOnForm(data.component.dialog.$node, "page[add_page_after]", data.component.uuid);

         // Current menu option needs to activate the (separate entity)
         // Add page menu to allow add page options to show.
         $("#ActivatedMenu_AddPage").trigger("component.open", {
           my: "left top",
           at: "right top",
           of: element
         });
         break;

    case "destination":
         event.preventDefault();
         new DialogApiRequest(element.href, {
           activator: element,
           buttons: [{
             text: view.text.dialogs.button_change_destination,
             click: function(dialog) {
               dialog.$node.find("form").submit();
             }
           }, {
             text: view.text.dialogs.button_cancel
           }]
         });
         break;

    case "delete":
          this.dialogConfirmationDelete.open({
            heading: app.text.dialogs.heading_delete.replace(/%{label}/, data.component.$node.data("page-heading")),
            ok: app.text.dialogs.button_delete_page
            }, function() {
            post(element.href, { _method: "delete" });
          });
         break;

    default: location.href = element.href;
  }
}


/* Controls form step Add page functionality
 **/
class PageAdditionMenu extends ActivatedMenu {
  constructor($node, dialog, config) {
    super($node, mergeObjects({
      activator_classname: $node.data("activator-classname"),
      container_id: $node.data("activated-menu-container-id"),
      activator_text: $node.data("activator-text")
    }, config));

    this.dialog = dialog;
    this.activator.$node.on("click.pageadditionmenu", function() {
      // Add handler for main 'Add page' button to clear any add_page_after values.
      updateHiddenInputOnForm(dialog.$node, "page[add_page_after]", "");
    });

  }
}

/* Controls what happens when user selects a page type.
 * 1). Clear page_type & component_type values in hidden form.
 * (if we then have new values):
 * 2). Set new page_type & component_type in hidden form.
 * 3). Close the open menu
 * 4). Open the form URL input dialog.
 **/
PageAdditionMenu.selection = function(event, data) {
  var $activator = data.activator.find("> a");
  var $form = this.dialog.$node; // Form sending information back to server.

  // First reset to remove any lingering values.
  updateHiddenInputOnForm($form, "page[page_type]", "");
  updateHiddenInputOnForm($form, "page[component_type]", "");

  // Then add any required values.
  updateHiddenInputOnForm($form, "page[page_type]", $activator.data("page-type"));
  updateHiddenInputOnForm($form, "page[component_type]", $activator.data("component-type"));
  data.component.close();
}


/* Form item context menus.
 * Create the context menus for each page thumbnail.
 **/
function createMenusForThumbnails(view) {
  $("[data-component='ItemActionMenu']").each((i, el) => {
    var menu = new PageActionMenu($(el), view.pageCreateDialog, {
      selection_event: "PageActionMenuSelection",
      preventDefault: true, // Stops the default action of triggering element.
      menu: {
        position: { at: "right+2 top-2" }
      }
    });

    view.addLastPointHandler(menu.activator.$node);
  });
}


/* Form overview Add page support.
 * Create the menu for Add Page functionality.
 **/
function createMenuForAddPage(view) {
  $("[data-component='PageAdditionMenu']").each(function(i) {
    var selection_event = "PageAdditionMenuSelection_" + i;
    var menu = new PageAdditionMenu($(this), view.pageCreateDialog, {
      selection_event: selection_event,
      menu: {
        position: { at: "right+2 top-2" } // Position second-level menu in relation to first.
      }
    });

    view.addLastPointHandler(menu.activator.$node);

    // Register event handler for selection of menu item.
    $(document).on(selection_event, function() {
      PageAdditionMenu.selection.bind(menu)
      view.pageCreateDialog.open();
    });
  });
}


/* Temporary fix for form overview Add Page button location.
 * Due to changes required for the updated Flow Overview
 * layout, the Add Page menu HTML has been relocated outside
 * of the original DIV.form-overview element. This move has
 * affected the location of the dynamically inserted menu
 * activator and resulting CSS positioning. To correct this
 * the function here moves the element back to the original
 * location, leaving the menu in it's new position.
 **/
function fixAddPageButtonPosition() {
  $("#form-overview .container").append($(".form-overview-button"));
}


/* Temporary fix for form overview scrolling and reactivation on resize.
 **/ 
function fixFormOverviewScroll() {
  // Fix for the scrolling of form overview.
  applyCustomOverviewWorkaround();
  let scrollTimeout;
  $(window).on("resize", function() {
    scrollTimeout = setTimeout(function() {
      clearTimeout(scrollTimeout);
      applyCustomOverviewWorkaround();
    }, 500);
  });
}


/* Quickfix workaround to try and fix scrolling issues for the form overview
 * when there are too many thumbnails to fix on the one page view.
 **/
function applyCustomOverviewWorkaround() {
  var $overview = $("#form-overview");
  var $container = $overview.find(" > .container");
  var containerWidth = $container.width();
  var overviewWidth = $overview.width();
  var offsetLeft = $overview.offset().left;
  var margin = 30; // Arbitrary number based on common
  var spacerForMenu = 250;
  var maxWidth = window.innerWidth - (margin * 2) - spacerForMenu;

  if(containerWidth > overviewWidth) {
    let left = ((containerWidth + spacerForMenu) - overviewWidth) / 2;
    if(left < offsetLeft) {
      $container.css("left", ~left);
    }
    else {
      $container.css("left", ~(offsetLeft - margin));
    }
  }

  $container.css("max-width", maxWidth); // Make sure to limit so a scrollbar can kick in, if necessary.
  $container.scrollLeft(containerWidth); // Align to right so Add page button is visible
  $overview.height($container.outerHeight(true));
}


/* TODO; Temporary resizing of frame (will be improved with ticket regarding scroll implementation
 *
 * Quickfix workaround to try and adjust the width of available view
 * area on the flow overview (otherwise restricted by container css).
 * --------------------------------------------------------------------------
 * THIS IS WIP AND BASED ON applyCustomOverviewWorkaround() SO CONTAINS SOME
 * VARIABLES THAT COULD BE USEFUL BUT, DUE TO LGTM SCRIPTS POINTING OUT THEIR
 * CURRENT LACK OF USE, THEY HAVE BEEN TEMPORARILY COMMENTED OUT.
 * --------------------------------------------------------------------------
 **/
function applyFlowOverviewWidthWorkaround($overview) {
  const SELECTOR_FLOW_ITEM = ".flow-item";
  //var $container = $overview.find(" > .container");
  //var containerWidth = $container.width();
  //var overviewWidth = $overview.width();
  //var offsetLeft = $overview.offset().left;
  var $items = $(SELECTOR_FLOW_ITEM, $overview);
  //var right = $items.last().position().left + $items.first().width();
  //var margin = 30; // Arbitrary number based on common
  //var maxWidth = window.innerWidth - (margin * 2);

  // Adjust the overview height.
  let lowestPoint = 0;
  $items.each(function() {
    var $current = $(this);
    var bottom = ($current.position().top + $current.height());
    if(bottom > lowestPoint) {
      lowestPoint = bottom;
    }
  });
  $overview.css("height", lowestPoint + "px");
}



/* Flow view positioning for design.
**/
function positionFlowItems($overview) {
  const SELECTOR_FLOW_BRANCH = ".flow-branch";
  const SELECTOR_FLOW_CONDITIONS = ".flow-conditions";
  const SELECTOR_FLOW_CONDITION = ".flow-condition";
  const SELECTOR_FLOW_EXPRESSIONS = ".flow-expression";
  const SELECTOR_FLOW_THUMBNAIL = ".flow-thumbnail";
  const SELECTOR_FLOW_ITEM = ".flow-item";
  const THUMBNAIL_HEIGHT = $(SELECTOR_FLOW_ITEM).eq(0).height();
  const THUMBNAIL_WIDTH = $(SELECTOR_FLOW_THUMBNAIL).eq(0).width();
  const SPACING_X = 100;
  const SPACING_Y = THUMBNAIL_HEIGHT / 2;
  const CONDITIONS_LEFT_SPACING = $(SELECTOR_FLOW_BRANCH).width() + SPACING_X;
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

    // Reduce any conditions columns, if required.
    if(maxExpressionWidth < $conditions.width()) {
      $conditions.css("width", maxExpressionWidth + "px");
    }

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
          top: (conditionY - $condition.height()) + "px"
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
      left += (CONDITIONS_LEFT_SPACING + $conditions.width());
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
                                <span class=\"match\">" + expression.operator + "</span> \
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
