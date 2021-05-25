/**
 * Pages Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality required to enhance FB Editor form pages with editable components.
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
const safelyActivateFunction = utilities.safelyActivateFunction;
const mergeObjects = utilities.mergeObjects;
const uniqueString = utilities.uniqueString;
const findFragmentIdentifier = utilities.findFragmentIdentifier;
const updateHiddenInputOnForm = utilities.updateHiddenInputOnForm;
const ActivatedMenu = require('./component_activated_menu');
const Question = require('./question');
const QuestionMenu = require('./component_activated_question_menu');
const DialogConfiguration = require('./component_dialog_configuration');
const editableComponent = require('./editable_components');
const DefaultController = require('./controller_default');
const ServicesController = require('./controller_services');

const ATTRIBUTE_DEFAULT_TEXT = "fb-default-text";
const SELECTOR_COLLECTION_FIELD_LABEL = "legend > :first-child";
const SELECTOR_COLLECTION_FIELD_HINT = "fieldset > .govuk-hint";
const SELECTOR_COLLECTION_ITEM = ".govuk-radios__item, .govuk-checkboxes__item";
const SELECTOR_DISABLED = "input:not(:hidden), textarea";
const SELECTOR_GROUP_FIELD_LABEL = "legend > :first-child";
const SELECTOR_HINT_STANDARD = ".govuk-hint";
const SELECTOR_LABEL_HEADING = "label h1, label h2, legend h1, legend h2";
const SELECTOR_LABEL_STANDARD = "label";

class PagesController extends DefaultController {
  constructor(app) {
    super(app);

    switch(app.page.action) {
      case "edit":
        PagesController.edit.call(this);
        break;
      case "create":
        PagesController.create.call(this);
        break;
    }
  }
}

/* ------------------------------
 * Setup for the Edit action view
 * ------------------------------ */
PagesController.edit = function() {
  var view = this;
  var $form = $("#editContentForm");
  this.$form = $form;
  this.editableContent = [];
  this.dialogConfiguration = createDialogConfiguration.call(this);

  workaroundForDefaultText(view);
  bindEditableContentHandlers(view);

  // Handle page-specific view customisations here.
  switch(view.type) {
    case "page.multiplequestions":
         editPageMultipleQuestionsViewCustomisations.call(view);
         break;

    case "page.singlequestion":
         // No customisations required for this view.
         break;

    case "page.content":
         editPageContentViewCustomisations.call(view);
         break;

    case "page.confirmation":
         // No customisations required for this view.
         break;

    case "page.checkanswers":
         editPageCheckAnswersViewCustomisations.call(view);
         break;
  }

  // Enhance any Add Content buttons
  $("[data-component=add-content]").each(function() {
    var $node = $(this);
    new AddContent($node, { $form: $form });
  });

  // Enhance any Add Component buttons.
  view.$document.on("AddComponentMenuSelection", AddComponent.MenuSelection.bind(view) );
  $("[data-component=add-component]").each(function() {
    var $node = $(this);
    new AddComponent($node, { $form: $form });
  });

  // Initialise questions
  setupQuestions.call(view);

  // Setting focus for editing.
  focusOnEditableComponent.call(view);
}


/* --------------------------------
 * Setup for the Create action view
 * -------------------------------- */
PagesController.create = function() {
  // Actually uses the Services controller due to view redirect on server.
  ServicesController.edit.call(this);
}



/* Gives add component buttons functionality to select a component type
 * from a drop menu, and update the 'save' form by activation of a 
 * global document event.
 * (see addComponentMenuSelection function)
 **/
class AddComponent {
  constructor($node) {
    var $list = $node.find("> ul");
    var $button = $node.find("> a");

    this.$list = $list;
    this.$button = $button;
    this.menu = new ActivatedMenu($list, {
      selection_event: "AddComponentMenuSelection",
      preventDefault: true, // Stops the default action of triggering element.
      activator: $button,
      menu: {
        position: { at: "right+2 top-2" }
      }
    });

    $node.addClass("AddComponent");
  }
}


/* Handle item selections on the AddComponent context menu elements.
 **/
AddComponent.MenuSelection = function(event, data) {
  var action = data.activator.data("action");
  updateHiddenInputOnForm(this.$form, "page[add_component]", action);
  this.$form.submit();
}


/* Gives add content buttons functionality to update the 'save' form.
 **/
class AddContent {
  constructor($node, config) {
    var $button = $node.find("> a");
    var fieldname = $node.data("fb-field-name") || "page[add_component]";
    this.$button = $button;
    this.$node = $node;

    $button.on("click.AddContent", function() {
      updateHiddenInputOnForm(config.$form, fieldname, "content");
      config.$form.submit();
    });

    $node.addClass("AddContent");
  }
}


/* Set focus on first editable component or, if a new component has been
 * added, the first element with that new component.
 **/
function focusOnEditableComponent() {
  var target = location.hash;
  if(target.match(/^[#\w\d_]+$/)) {
    // Newly added component with fragment identifier so find first
    // first editable item of last component.
    let $newComponent = $(target);
    if($newComponent.length) {
      $newComponent.data("instance").focus();
    }
  }
  else {
    // Standard editable page so find first editable item.
    if(this.editableContent.length > 0) {
      this.editableContent[0].focus();
    }
  }
}


/* Controls all the Editable Component setup for each page.
 * TODO: Add more description on how this works.
 **/
function bindEditableContentHandlers(view) {
  var $editContentForm = $("#editContentForm");
  var $saveButton = $editContentForm.find(":submit");
  if($editContentForm.length) {
    $saveButton.prop("disabled", true); // disable until needed.

    $(".fb-editable").each(function(i, node) {
      var $node = $(node);
      view.editableContent.push(editableComponent($node, {
        editClassname: "active",
        data: $node.data("fb-content-data"),
        attributeDefaultText: ATTRIBUTE_DEFAULT_TEXT,
        filters: {
          _id: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          },
          value: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          }
        },
        form: $editContentForm,
        id: $node.data("fb-content-id"),

        // Selectors for editable component labels/legends/hints, etc.
        selectorTextFieldLabel: SELECTOR_LABEL_HEADING, // Also used by Number
        selectorTextFieldHint: SELECTOR_HINT_STANDARD,   // Also used by Number
        selectorTextareaFieldLabel: SELECTOR_LABEL_HEADING,
        selectorTextareaFieldHint: SELECTOR_HINT_STANDARD,
        selectorGroupFieldLabel: SELECTOR_GROUP_FIELD_LABEL, // Used by Date
        selectorGroupFieldHint: SELECTOR_HINT_STANDARD,      // Used by Date
        selectorCollectionFieldLabel: SELECTOR_COLLECTION_FIELD_LABEL,  // Used by Radios
        selectorCollectionFieldHint: SELECTOR_COLLECTION_FIELD_HINT,    // Used by Radios
        selectorCollectionItem: SELECTOR_COLLECTION_ITEM, // Used by Radio and Checkbox option parent
        selectorComponentCollectionItemLabel: SELECTOR_LABEL_STANDARD, // Used by Radio and Checkbox options
        selectorComponentCollectionItemHint: SELECTOR_HINT_STANDARD,   // Used by Radio and Checkbox options
        // Other selectors
        selectorDisabled: SELECTOR_DISABLED,

        text: {
          addItem: view.text.actions.option_add,
          removeItem: view.text.actions.option_remove,
          default_content: view.text.defaults.content
        },

        onCollectionItemClone: function($node) {
           // @node is the collection item (e.g. <div> wrapping <input type=radio> and <label> elements)
           // Runs after the collection item has been cloned, so further custom manipulation can be
           // carried out on the element.
           $node.find("label").text(view.text.defaults.option);
           $node.find("span").text(view.text.defaults.option_hint);
        },
        onItemAdd: function($node) {
          // @$node (jQuery node) Node (instance.$node) that has been added.
          // Runs after adding a new Collection item.
          // This adjust the view to wrap Remove button with desired menu component.
          //
          // This is not very good but expecting it to get significant rework when
          // we add more menu items (not for MVP).
          collectionItemControlsInActivatedMenu($node, {
            activator_text: view.text.actions.edit,
            classnames: "editableCollectionItemControls"
          });
        },
        onItemRemove: function(item) {
          // @item (EditableComponentItem) Item to be deleted.
          // Runs before removing an editable Collection item.
          // Provides an opportunity for clean up.
          var activatedMenu = item.$node.data("ActivatedMenu");
          if(activatedMenu) {
            activatedMenu.activator.$node.remove();
            activatedMenu.$node.remove();
            activatedMenu.container.$node.remove();
          }
        },
        onItemRemoveConfirmation: function(item) {
          // @item (EditableComponentItem) Item to be deleted.
          // Runs before onItemRemove when removing an editable Collection item.
          // Currently not used but added for future option and consistency
          // with onItemAdd (provides an opportunity for clean up).
          view.dialogConfirmationDelete.content = {
            heading: view.text.dialogs.heading_delete_option.replace(/%{option label}/, item._elements.label.$node.text()),
            ok: view.text.dialogs.button_delete_option
          };
          view.dialogConfirmationDelete.confirm({}, function() {
            item.component.remove(item);
          });
        },
        onSaveRequired: function() {
          // Code detected something changed to
          // make the submit button available.
          $saveButton.prop("disabled", false);
        },
        type: $node.data("fb-content-type")
      }));
    });

    // If any Collection items are present with ability to be removed, we need
    // to find them and scoop up the Remove buttons to put in menu component.
    $(".EditableComponentCollectionItem").each(function() {
      collectionItemControlsInActivatedMenu($(this), {
       activator_text: view.text.actions.edit,
        classnames: "editableCollectionItemControls"
      });
    });

    // Add handler to activate save functionality from the independent 'save' button.
    $editContentForm.on("submit", (e) => {
      for(var i=0; i<view.editableContent.length; ++i) {
        view.editableContent[i].save();
      }
    });
  }
}


/* Finds elements to wrap in Activated Menu component.
 * Best used for dynamically generated elements that have been injected into the page
 * through JS enhancement. If items existed in the template code, you could probably
 * just use an easier method such as applyMenus() function.
 *
 * This function will basically find desired elments, wrap each one with an <li> tag,
 * add those to a new <ul> element, and then create an ActivateMenu component from
 * that structure.
 *
 * @selector (String) jQuery compatible selector to find elements for menu inclusion.
 * @$node  (jQuery node) Wrapping element/container that should hold the elements sought.
 * effects and wraps them with the required functionality.
 **/
function collectionItemControlsInActivatedMenu($item, config) {
  var $elements = $(".EditableCollectionItemRemover", $item);
  if($elements.length) {
    $elements.wrapAll("<ul class=\"govuk-navigation\"></ul>");
    $elements.wrap("<li></li>");
    let menu = new ActivatedMenu($elements.parents("ul"), {
      activator_text: config.activator_text,
      container_classname: config.classnames,
      container_id: uniqueString("activatedMenu-"),
      menu: {
        position: { my: "left top", at: "right-15 bottom-15" } // Position second-level menu in relation to first.
      }
    });

    $item.data("ActivatedMenu", menu);
  }
}


/* Create standard Dialog Confirmation component with 'ok' and 'cancel' type buttons.
 * Component allows passing a function to it's 'confirm()' function so that actions
 * can be played out on whether user clicks 'ok' or 'cancel'.
 **/
function createDialogConfiguration() {
  var $template = $("[data-component-template=DialogConfiguration]");
  var $node = $($template.text());
  return new DialogConfiguration($node, {
    autoOpen: false,
    cancelText: $template.data("text-cancel"),
    okText: $template.data("text-ok"),
    classes: {
      "ui-activator": "govuk-button fb-govuk-button",
      "ui-button": "govuk-button",
      "ui-dialog": $template.data("classes")
    }
  });
}


/* Apply functionality for Question Menu that handles the settings
 * for the question and page view.
 **/
function setupQuestions() {
  var view = this;
  var questionMenuTemplate = $("[data-component-template=QuestionMenu]");

  $("[data-fb-content-data]").not("[data-fb-content-type='content']").each(function() {

    // Initialise the question as an object.
    var $node = $(this);
    var question = new Question($node, {
      data: $node.data("fb-content-data"),
      view: view
    });

    // Create a menu for Question property editing.
    var $ul = $(questionMenuTemplate.html());
    var $target = $(SELECTOR_LABEL_HEADING, $node);
    //var $optionalFlag = $("<span class=\"flag\">&nbsp;" + view.text.question_optional_flag + "</span>").css("font-size", $target.get(0).style.fontSize);

    // Need to make sure $ul is added to body before we try to create a QuestionMenu out of it.
    view.$body.append($ul);

    new QuestionMenu($ul, {
      activator_text: questionMenuTemplate.data("activator-text"),
      $target: $target,
      question: question,
      view: view,
      question_property_fields: $("[data-component-template=QuestionPropertyFields]").html(),
      onSetRequired: function(questionMenu) {
        setQuestionRequiredFlag(question, $target, view.text.question_optional_flag);
      }
    });

    // Check view state on element edits
    $target.on("blur", function() {
      setQuestionRequiredFlag(question, $target, view.text.question_optional_flag);
    });


    // Set initial view state
    setQuestionRequiredFlag(question, $target, view.text.question_optional_flag);
  });
}


/* The design calls for a visual indicator that the question is optional.
 * This function is to handle the adding the extra element.
 **/
function setQuestionRequiredFlag(question, $target, text) {
  var regExpTextWithSpace = " " + text.replace(/(\(|\))/mig, "\\$1"); // Need to escape parenthesis for RegExp
  var textWithSpace =  " " + text;
  var re = new RegExp(regExpTextWithSpace + "$");

  // Since we always remove first we can add knowing duplicates should not happen.
  $target.text($target.text().replace(re, ""));
  if(!question.data().validation.required) {
    $target.text($target.text() + textWithSpace);
  }

  // If we've changed the $target content, or the eitor has, we
  // need to check whether required flag needs to show, or not.
  $target.data("instance").update();
}


/* Due to limitations in using the GDS templates, we cannot
 * add appropriate HTML attributes to relevant elements in
 * both radio and checkbox hints. This is a workaround to
 * add them, so fixes missing default text without affecting
 * the current method of finding them view fb-default-text
 * attribute.
 **/
function workaroundForDefaultText(view) {
  $(".govuk-radios__item, .govuk-checkboxes__item").each(function() {
    var $this = $(this);
    var $span = $this.find("span");
    $span.attr("data-" + ATTRIBUTE_DEFAULT_TEXT, view.text.defaults.option_hint);
  });
}


/**************************************************************/
/* View customisations for PageController.edit actions follow */
/**************************************************************/


function editPageContentViewCustomisations() {
  var $button1 = $("[data-component=add-content]");
  var $target = $("#new_answers :submit");
  $target.before($button1);
}


function editPageCheckAnswersViewCustomisations() {
  var $button1 = $("[data-component=add-content]");
  var $target1 = $(".fb-editable").last();
  var $button2 = $button1.clone();
  var $target2 = $("#answers-form dl").first();
  $target1.after($button1);
  $target2.before($button2);
  $button2.attr("data-fb-field-name", "page[add_extra_component]");
}


function editPageMultipleQuestionsViewCustomisations() {
  var $button1 = $("[data-component=add-component]");
  var $target = $("#new_answers input:submit");
  $target.before($button1);
}


module.exports = PagesController;
