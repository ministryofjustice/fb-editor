/**
 * Question
 * ----------------------------------------------------
 * Description:
 * Basic construct of a standard question
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 **/

const { mergeObjects, filterObject } = require("./utilities");
const editableComponent = require("./editable_components").editableComponent;
const QuestionMenu = require("./components/menus/question_menu");

const ATTRIBUTE_DEFAULT_TEXT = "fb-default-text";
const SELECTOR_DISABLED =
  "input:not(:hidden), textarea:not([data-element]), select";
const SELECTOR_LABEL_HEADING = "label h1, label h2, legend h1, legend h2";

class Question {
  constructor($node, config) {
    var $heading = $(SELECTOR_LABEL_HEADING, $node);
    var conf = mergeObjects(
      {
        // Config defaults
        attributeDefaultText: ATTRIBUTE_DEFAULT_TEXT,
        data: $node.data("fb-content-data"), // TODO: Phase this out because Question should control data
        editClassname: "active",
        id: $node.data("fb-content-id"),
        selectorDisabled: SELECTOR_DISABLED,
        text: {
          // optionalFlag: Replaced with design requirement
        },
        type: $node.data("fb-content-type"),
        defaultLabelValue: $node.data("fb-default-value"),
        defaultItemLabelValue: $node.data("fb-default-item-value"),
        view: {},
      },
      config,
    );

    $node.addClass("Question");
    this.config = conf;
    this.data = $node.data("fb-content-data");
    this.$node = $node;
    this.$heading = $heading;
    this.editable = editableComponent($node, conf);
    this.menu = createQuestionMenu.call(this);
    this.labels = this.config.text.aria.question;

    // Check view state on element edit or interaction and set initial state.
    this.$heading.on("focus", () => {
      this.$node.addClass("active");
    });
    $heading.on("blur", () => {
      this.$node.removeClass("active");
      this.setRequiredFlag.bind(this);
    });
    this.setRequiredFlag();
    this.addAccessibleLabels();
  }

  get required() {
    return this.data.validation.required;
  }

  set required(content) {
    var arr = content.find("form").serializeArray();
    for (var i = 0; i < arr.length; ++i) {
      this.data.validation[arr[i].name] = arr[i].value == "true" ? true : false;
    }

    this.menu.setEnabledValidations();
    this.setRequiredFlag();
  }

  /*
   * Applies the validation settings to the questions data.validations key
   * @param {Object} config - the settings for the validation to be applied
   *                          expected format: { validationName: value }
   *
   */
  set validation(config) {
    let [validationName, _] = Object.entries(config)[0];
    let data = this.data.validation;

    // Merge our new validation data with the current data on the question
    data = mergeObjects(data, config);
    // Remove keys with empty values
    data = filterObject(data, ([_, val]) => val != "");

    // Ensure we don't have conflicting min_length/word and max_length/word keys
    switch (validationName) {
      case "min_length":
        data = filterObject(data, ([key, _]) => key != "min_word");
        break;
      case "min_word":
        data = filterObject(data, ([key, _]) => key != "min_length");
        break;
      case "max_length":
        data = filterObject(data, ([key, _]) => key != "max_word");
        break;
      case "max_word":
        data = filterObject(data, ([key, _]) => key != "max_length");
        break;
    }

    this.data.validation = data;
    this.menu.setEnabledValidations();
    this.editable.emitSaveRequired();
  }

  /* The design calls for a visual indicator that the question is optional.
   * This function is to handle the adding the extra element.
   **/
  setRequiredFlag() {
    var text = this.config.text.optionalFlag;
    // Escape the parentheses
    var escapedTextWithSpace = " " + text.replace(/(\(|\))/gim, "\\$1");
    // $ - must be at the end of the string
    // i - case insensitive
    var regex = new RegExp(escapedTextWithSpace + "$", "i");

    if (this.required) {
      this.$heading.text(this.$heading.text().replace(regex, ""));
    } else {
      if (!this.$heading.text().match(regex)) {
        this.$heading.text(`${this.$heading.text()} ${text}`);
      }
    }

    // If we've changed the this.$heading content, or the editor has, we
    // need to check whether required flag needs to show, or not.
    this.$heading.data("instance").update();
  }

  focus() {
    this.editable.focus();
  }

  remove() {
    // TODO: Replace with proper mechanism to remove this workaround
    this.editable.remove();
  }

  save() {
    // TODO: Replace with proper mechanism to remove this workaround
    this.editable.save();
  }

  addAccessibleLabels() {
    // Set an accessible label for the editable heading
    this.$heading.attr(
      "aria-label",
      this.labels.title.replace("{{type}}", this.config.type),
    );

    // Remove the description from the fieldset element as it is confusing when editing
    this.$node.find("fieldset").removeAttr("aria-describedby");

    // We add this so that in the editor the text in the legend is not used as
    // the group label, as it gets confusing
    this.$node
      .find("fieldset > legend")
      .attr(
        "aria-label",
        this.labels.legend.replace("{{type}}", this.config.type),
      );

    // Accessible label and description for the question hint text (where present)
    this.$node.find(".govuk-hint").first().attr("aria-label", this.labels.hint);

    // For the label wrapping the heading we provide an accessible group name
    // Remove the 'for' attribute, otherwise clicking will focus the questions
    // form field
    if (!this.$node.find("fieldset").length > 0) {
      this.$node.find("label.govuk-label").first().attr("for", "");
    }

    // Accessibly prevent input in editor mode
    // 1. aria-disabled : communicate disabled state to AT
    // 2. readonly : prevent text input
    // 3. aria-label : provide an screen-reader label for the field
    // 4. aria-describedby : explain why field is disabled
    // 5. pointer-events : mouse interaction (required for <select>)
    // 6. prevent click events
    // 7. prevent space or enter triggering field (required for <select>)
    this.$node
      .find(SELECTOR_DISABLED)
      .attr("aria-disabled", true)
      .attr("readonly", "")
      .attr("aria-label", this.labels.answer)
      .attr("aria-describedby", "disabled_input_description")
      .css("pointer-events", "none")
      .on("click", (e) => {
        e.preventDefault();
        return false;
      })
      .on("keydown", (e) => {
        if (e.key == " " || e.key == "Enter") {
          e.preventDefault();
          return false;
        }
      });
  }
}

/* Create a menu for Question property editing.
 **/
function createQuestionMenu() {
  var question = this;
  var template = $(
    "[data-component-template=QuestionMenu_" + question.data._uuid + "]",
  );
  var $ul = $(template.html());

  // Need to make sure $ul is added to body before we try to create a QuestionMenu out of it.
  $(document.body).append($ul);

  return new QuestionMenu($ul, {
    activator_text: template.data("activator-text"),
    $target: question.$heading,
    question: question,
    menu: {
      position: {
        my: "left top",
        at: "left top",
      },
    },
  });
}

module.exports = Question;
