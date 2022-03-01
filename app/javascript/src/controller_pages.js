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

const editable_components = require('./editable_components');
const EditableElement = editable_components.EditableElement;
const Content = require('./content');

const CheckboxesQuestion = require('./question_checkboxes');
const RadiosQuestion = require('./question_radios');
const DateQuestion = require('./question_date');
const TextQuestion = require('./question_text');
const TextareaQuestion = require('./question_text');

const DialogConfiguration = require('./component_dialog_configuration');
const DialogApiRequest = require('./component_dialog_api_request');
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
  var dataController = new DataController();

  this.$editable = $(".fb-editable");
  this.dataController = dataController;
  this.dialogConfiguration = createDialogConfiguration.call(this);

  workaroundForDefaultText(view);
  enhanceContent(view);
  enhanceQuestions(view);

  // Handle page-specific view customisations here.
  switch(view.type) {
    case "page.multiplequestions":
         editPageMultipleQuestionsViewCustomisations.call(view);
         break;

    case "page.singlequestion":
         editPageSingleQuestionViewCustomisations.call(view);
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
    new AddContent($node, { $form: dataController.$form });
  });

  // Enhance any Add Component buttons.
  view.$document.on("AddComponentMenuSelection", AddComponent.MenuSelection.bind(view) );
  $("[data-component=add-component]").each(function() {
    var $node = $(this);
    new AddComponent($node, { $form: dataController.$form });
  });

  // Setting focus for editing.
  focusOnEditableComponent.call(view);


  // Bind listeners
  // --------------

  addQuestionMenuListeners(view);
  addContentMenuListeners(view);

  dataController.saveRequired(false);
  this.$document.on("SaveRequired", () => dataController.saveRequired(true) );
}


/* --------------------------------
 * Setup for the Create action view
 * -------------------------------- */
PagesController.create = function() {
  // Actually uses the Services controller due to view redirect on server.
  ServicesController.edit.call(this);
}


class DataController {
  constructor() {
    var controller = this;
    var $form = $("#editContentForm");
    $form.on("submit", controller.update);
    this.$form = $form;
  }

  saveRequired(required) {
    if(required) {
      this.$form.find(":submit").prop("disabled", false);
    }
    else {
      this.$form.find(":submit").prop("disabled", true);
    }
  }

  update() {
    $(".fb-editable").each(function() {
      $(this).data("instance").save();
    });
  }
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
  updateHiddenInputOnForm(this.dataController.$form, "page[add_component]", action);
  this.dataController.$form.submit();
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


/* Question Menu needs to interact with Dialog components before
 * running any action, so we need to work with listeners to coordinate
 * between different component/widgets/functionality, etc.
 **/
function addQuestionMenuListeners(view) {
  var templateContent = $("[data-component-template=QuestionPropertyFields]").html();

  // QuestionMenuSelectionRemove
  view.$document.on("QuestionMenuSelectionRemove", function(event, question) {
    var questionUuid = question.data._uuid;
    var apiUrl = question.menu.selectedItem.data('apiPath').replace('question_uuid', questionUuid);
    
    new DialogApiRequest(apiUrl, {
      activator: question.menu.selectedItem,
      closeOnClickSelector: ".govuk-button",

      build: function(dialog) {
        // Find and correct (make work!) any method:delete links
        dialog.$node.find("[data-method=delete]").on("click", function(e) {
          e.preventDefault();
      // Workaround solution that doesn't require extra backend work
      // 1. First remove component from view
          question.$node.hide();
      // 2. Update form (in case anything else has changed)
          view.dataController.update();
      // 3. Remove corresponding component from form
          question.remove();
      // 4. Trigger save required (to enable Save button)
          view.dataController.saveRequired(true);
        });
      }
    });
  });

  // QuestionMenuSelectionRequired
  view.$document.on("QuestionMenuSelectionRequired", function(event, question) {
    var html = $(templateContent).filter("[data-node=required]").get(0).outerHTML;
    var required = question.data.validation.required;
    var regex = new RegExp("(input.*name=\"required\".*value=\"" + required + "\")", "mig");
    html = html.replace(regex, "$1 checked=\"true\"");
    view.dialogConfiguration.open({
      content: html
    }, (content) => { question.required = content } );
  });
}


/* Content Menu needs to interact with Dialog components before
 * running any action, so we need to work with listeners to coordinate
 * between different component/widgets/functionality, etc.
 **/
function addContentMenuListeners(view) {
  var templateContent = $("[data-component-template=ContentPropertyFields]").html();

  // ContentMenuSelectionRemove
  view.$document.on("ContentMenuSelectionRemove", function(event, component) {
    var html = $(templateContent).filter("[data-node=remove]").text();
    view.dialogConfirmationDelete.open({
      heading: html.replace(/#{label}/, ""),
      ok: view.text.dialogs.button_delete_component
      }, function() {
      // Workaround solution that doesn't require extra backend work
      // 1. First remove component from view
      component.$node.hide();

      // 2. Update form (in case anything else has changed)
      view.dataController.update();

      // 3. Remove corresponding component from form
      component.remove();

      // 4. Trigger save required (to enable Save button)
      view.dataController.saveRequired(true); // 4
    });
  });
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
    $(".fb-editable").eq(0).focus();
  }
}


/* Add edit functionality and component enhancements to content.
 * Affects simple elements (e.g. Headings) and full text blocks.
 **/
function enhanceContent(view) {
  view.$editable.filter("[data-fb-content-type=element]").each(function(i, node) {
    var $node = $(node);
    new EditableElement($node, {
      editClassname: "active",
      attributeDefaultText: ATTRIBUTE_DEFAULT_TEXT,
      form: view.dataController.$form,
      id: $node.data("fb-content-id"),

      text: {
        default_content: view.text.defaults.content
      },

      type: $node.data("fb-content-type")
    });
  });

  view.$editable.filter("[data-fb-content-type=content]").each(function(i, node) {
    var $node = $(node);
    new Content($node, {
      form: view.dataController.$form,
      text: {
        default_content: view.text.defaults.content
      }
    });
  });
}


/* Add edit functionality and component enhancements to questions.
 **/
function enhanceQuestions(view) {
  view.$editable.filter("[data-fb-content-type=text], [data-fb-content-type=email], [data-fb-content-type=number], [data-fb-content-type=upload]").each(function(i, node) {
    var question = new TextQuestion($(this), {
      form: view.dataController.$form,
      text: {
        default_content: view.text.defaults.content,
        optionalFlag: view.text.question_optional_flag
      }
    });
    view.addLastPointHandler(question.menu.activator.$node);
  });

  view.$editable.filter("[data-fb-content-type=date]").each(function(i, node) {
    var question = new DateQuestion($(this), {
      form: view.dataController.$form,
      text: {
        optionalFlag: view.text.question_optional_flag
      }
    });
    view.addLastPointHandler(question.menu.activator.$node);
  });

  view.$editable.filter("[data-fb-content-type=textarea]").each(function(i, node) {
    var question = new TextareaQuestion($(this), {
      form: view.dataController.$form,
      text: {
        optionalFlag: view.text.question_optional_flag
      }
    });
    view.addLastPointHandler(question.menu.activator.$node);
  });

  view.$editable.filter("[data-fb-content-type=checkboxes]").each(function(i, node) {
    var question = new CheckboxesQuestion($(this), {
      form: view.dataController.$form,
      text: {
        edit: view.text.actions.edit,
        itemAdd: view.text.option_add,
        itemRemove: view.text.option_remove,
        option: view.text.defaults.option,
        optionHint: view.text.defaults.option_hint,
        optionalFlag: view.text.question_optional_flag,
        aria: {
          answers: view.text.aria.answers
        }
      },

      onItemRemoveConfirmation: function(item) {
        // @item (EditableComponentItem) Item to be deleted.
        // Runs before onItemRemove when removing an editable Collection item.
        // Currently not used but added for future option and consistency
        // with onItemAdd (provides an opportunity for clean up).
        view.dialogConfirmationDelete.open({
          heading: view.text.dialogs.heading_delete_option.replace(/%{option label}/, item._elements.label.$node.text()),
          ok: view.text.dialogs.button_delete_option
          }, function() {
          item.component.removeItem(item);
        });
      }


    });
    view.addLastPointHandler(question.menu.activator.$node);
  });

  view.$editable.filter("[data-fb-content-type=radios]").each(function(i, node) {
    var question = new RadiosQuestion($(this), {
      form: view.dataController.$form,
      text: {
        edit: view.text.actions.edit,
        itemAdd: view.text.option_add,
        itemRemove: view.text.option_remove,
        option: view.text.defaults.option,
        optionHint: view.text.defaults.option_hint,
        optionalFlag: view.text.question_optional_flag,
        aria: {
          answers: view.text.aria.answers
        }
      },

      onItemRemoveConfirmation: function(item) {
        // @item (EditableComponentItem) Item to be deleted.
        // Runs before onItemRemove when removing an editable Collection item.
        // Currently not used but added for future option and consistency
        // with onItemAdd (provides an opportunity for clean up).
        view.dialogConfirmationDelete.open({
          heading: view.text.dialogs.heading_delete_option.replace(/%{option label}/, item._elements.label.$node.text()),
          ok: view.text.dialogs.button_delete_option
          }, function() {
          item.component.removeItem(item);
        });
      }


    });
    view.addLastPointHandler(question.menu.activator.$node);
  });
}


/* Create standard Dialog Confirmation component with 'ok' and 'cancel' type buttons.
 * Component allows passing a function to it's 'open()' function so that actions
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
    var $span = $this.find(".govuk-hint");
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
  accessibilityQuestionViewEnhancements(this);
}


function editPageSingleQuestionViewCustomisations() {
  // Hide menu options not required for SingleQuestion page
  $(".QuestionMenu [data-action=remove]").hide();
  accessibilityQuestionViewEnhancements(this);
}

/* Aria accessibility view inclusions.
 * These are being added using JS because the views are controlled by
 * Metadata Presenter making direct changes more difficult and able to
 * impact pre-approved accessibility results in the runner that already
 * has sufficient level of accessibility support.
 * The Editor already requires JS for correct functionality so we can
 * safely assume full JS availability.
 **/
function accessibilityQuestionViewEnhancements(view) {
  $(".fb-section_heading").attr("aria-label", view.text.aria.section_header);
  $(".Question h1, .Question h2").attr("aria-label", view.text.aria.question);
  $(".govuk-hint").attr("aria-label", view.text.aria.hint);
}

module.exports = PagesController;
