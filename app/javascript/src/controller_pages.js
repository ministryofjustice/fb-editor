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
const updateHiddenInputOnForm = utilities.updateHiddenInputOnForm;
const ActivatedMenu = require('./component_activated_menu');
const EditableElement = require('./editable_components').EditableElement;

const CheckboxesComponent = require('./component_checkboxes');
const RadiosComponent = require('./component_radios');
const DateComponent = require('./component_date');
const TextComponent = require('./component_text');
const TextareaComponent = require('./component_text');

const DialogConfiguration = require('./component_dialog_configuration');
const DefaultController = require('./controller_default');
const ServicesController = require('./controller_services');

const ATTRIBUTE_DEFAULT_TEXT = "fb-default-text";


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
  enhanceQuestions(view);

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

  // Setting focus for editing.
  focusOnEditableComponent.call(view);


  // Bind listeners
  // --------------

  // QuestionMenuSelectionRequired
  this.$document.on("QuestionMenuSelectionRequired", function(event, question) {
    var dialog = view.dialogConfiguration;
    // TODO: Expect field_content to change when add more property fields
    var field_content = $("[data-component-template=QuestionPropertyFields]").html();
    var required = question.data.validation.required;
    var regex = new RegExp("(input.*name=\"required\".*value=\"" + required + "\")", "mig");
    field_content = field_content.replace(regex, "$1 checked=\"true\"");
    dialog.configure({
      content: field_content
    }, (content) => { question.required = content } );
  });
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
function enhanceQuestions(view) {
  var $editContentForm = $("#editContentForm");
  var $saveButton = $editContentForm.find(":submit");
  var $editable = $(".fb-editable");

  if($editContentForm.length) {
    $saveButton.prop("disabled", true); // disable until needed.

    $editable.filter("[data-fb-content-type=text], [data-fb-content-type=number]").each(function(i, node) {
      view.editableContent.push(new TextComponent($(this), {
        form: $editContentForm,
        text: {
          default_content: view.text.defaults.content,
          optionalFlag: view.text.question_optional_flag
        }
      }));
    });

    $editable.filter("[data-fb-content-type=date]").each(function(i, node) {
      view.editableContent.push(new DateComponent($(this), {
        form: $editContentForm,
        text: {
          optionalFlag: view.text.question_optional_flag
        }
      }));
    });

    $editable.filter("[data-fb-content-type=textarea]").each(function(i, node) {
      view.editableContent.push(new TextareaComponent($(this), {
        form: $editContentForm,
        text: {
          optionalFlag: view.text.question_optional_flag
        }
      }));
    });

    $editable.filter("[data-fb-content-type=checkboxes]").each(function(i, node) {
      view.editableContent.push(new CheckboxesComponent($(this), {
        form: $editContentForm,
        text: {
          edit: view.text.actions.edit,
          option: view.text.defaults.option,
          optionHint: view.text.defaults.option_hint,
          optionalFlag: view.text.question_optional_flag
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
        }
      }));
    });

    $editable.filter("[data-fb-content-type=radios]").each(function(i, node) {
      view.editableContent.push(new RadiosComponent($(this), {
        form: $editContentForm,
        text: {
          edit: view.text.actions.edit,
          option: view.text.defaults.option,
          optionHint: view.text.defaults.option_hint,
          optionalFlag: view.text.question_optional_flag
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
        }
      }));
    });

    $editable.filter("[data-fb-content-type=element]").each(function(i, node) {
      var $node = $(node);
      view.editableContent.push(new EditableElement($node, {
        editClassname: "active",
        attributeDefaultText: ATTRIBUTE_DEFAULT_TEXT,
        form: $editContentForm,
        id: $node.data("fb-content-id"),

        text: {
          default_content: view.text.defaults.content
        },

        onSaveRequired: function() {
          // Code detected something changed to
          // make the submit button available.
          $saveButton.prop("disabled", false);
        },
        type: $node.data("fb-content-type")
      }));
    });

    // Add handler to activate save functionality from the independent 'save' button.
    $editContentForm.on("submit", (e) => {
      for(var i=0; i<view.editableContent.length; ++i) {
        view.editableContent[i].save();
      }
    });
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
