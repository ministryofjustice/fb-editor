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
const mergeObjects = utilities.mergeObjects;
const post = utilities.post;
const updateHiddenInputOnForm = utilities.updateHiddenInputOnForm;
const ActivatedMenu = require('./component_activated_menu');
const ActivatedDialog = require('./component_activated_dialog');
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
  let $document = $(document);
  // Bind document event listeners to control functionality not specific to a single component or where
  // a component can be activated by more than one element (prevents complicated multiple element binding/handling).
  $document.on("PageActionMenuSelection", pageActionMenuSelection.bind(this) );

  // Create dialog for handling new page input and error reporting.
  let pageCreateDialog = new PageCreateDialog(this, $("[data-component='PageCreateDialog']"));


  // Create the context menus for each page thumbnail.
  $("[data-component='PageActionMenu']").each((i, el) => {
    new PageActionMenu($(el), pageCreateDialog, {
      selection_event: "PageActionMenuSelection",
      preventDefault: true, // Stops the default action of triggering element.
      menu: {
        position: { at: "right+2 top-2" }
      }
    });
  });

  // Create the menu for Add Page functionality.
  $("[data-component='PageAdditionMenu']").each(function(i) {
    var selection_event = "PageAdditionMenuSelection_" + i;
    var menu = new PageAdditionMenu($(this), pageCreateDialog, {
      selection_event: selection_event,
      menu: {
        position: { at: "right+2 top-2" } // Position second-level menu in relation to first.
      }
    });

    $document.on(selection_event, PageAdditionMenu.selection.bind(menu) );
  });

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


/* Wrap the create page form in a dialog effect.
 * Errors will also show here on page return.
 **/
class PageCreateDialog {
  constructor(page, $node, config) {
    var pageCreateDialog = this;
    var $form = $node.find("form");
    var $submit = $form.find(":submit");
    var $errors = $node.find(".govuk-error-message");

    var dialog = new ActivatedDialog($node, {
      autoOpen: $errors.length ? true: false,
      cancelText: $node.data("cancel-text"),
      okText: $submit.val(),
      activatorText: $node.data("activator-text"),
      classes: {
        "ui-button": "govuk-button",
        "ui-activator": "govuk-button fb-govuk-button"
      },
      onOk: () => {
        pageCreateDialog.$form.submit();
      },
      onClose: () => {
        pageCreateDialog.clearErrors();
      }
    });

    // Disable button as we're replacing it.
    $submit.attr("disabled", true);
    this.dialog = dialog;
    this.$form = $form;
    this.$submit = $submit;
    this.$errors = $errors;
  }

  clearErrors() {
    this.$errors.remove();
    this.$errors.parents().removeClass(".govuk-form-group--error");
  }
}


/* Controls form step add/edit/delete/preview controls
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
 * TODO: What are other actions?
 **/
function pageActionMenuSelection(event, data) {
  var element = data.original.element;
  var action = data.activator.data("action");
  switch(action) {
    case "edit":
         location.href = element.href;
         break;

    case "preview":
         window.open(element.href);
         break;

    case "add":
         // Set the 'add_page_here' value in form.
         // This should be a uuid value if from thumbnail context menu, of
         // just set it to blank string if from the main 'Add page' button.
         updateHiddenInputOnForm(data.component.dialog.$form, "page[add_page_after]", data.component.uuid);

         // Current menu option needs to activate the (separate entity)
         // Add page menu to allow add page options to show.
         $("#ActivatedMenu_AddPage").trigger("component.open", {
           my: "left top",
           at: "right top",
           of: element
         });
         break;

    case "delete":
          this.dialogConfirmationDelete.content = {
            heading: app.text.dialogs.heading_delete.replace(/%{label}/, data.component.$node.data("page-heading")),
            ok: app.text.dialogs.button_delete_page
          };
          this.dialogConfirmationDelete.confirm({}, function() {
            post(element.href, { _method: "delete" });
          });
         break;

    default: console.log(data.activator.href);
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
      updateHiddenInputOnForm(dialog.$form, "page[add_page_after]", "");
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
  var form = this.dialog.$form; // Form sending information back to server.

  // First reset to remove any lingering values.
  updateHiddenInputOnForm(form, "page[page_type]", "");
  updateHiddenInputOnForm(form, "page[component_type]", "");

  // Then add any required values.
  if($activator.length) {
    updateHiddenInputOnForm(form, "page[page_type]", $activator.data("page-type"));
    updateHiddenInputOnForm(form, "page[component_type]", $activator.data("component-type"));

    data.component.close();
    $("#new-page-create-dialog").dialog("open");
  }
}


/* Quickfix workaround to try and fix scrolling issues for the form overview
 * when there are too many thumbnails to fix on the one page view.
 **/
function applyCustomOverviewWorkaround() {
  var $overview = $("#form-overview");
  var $container = $overview.find(" > .container");
  var $button = $(".form-overview_button")
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



module.exports = ServicesController;
