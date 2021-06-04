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
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const updateHiddenInputOnForm = utilities.updateHiddenInputOnForm;
const editableComponent = require('./editable_components').editableComponent;

const ATTRIBUTE_DEFAULT_TEXT = "fb-default-text";
const SELECTOR_DISABLED = "input:not(:hidden), textarea";

class Question {
  constructor($node, config) {
    var conf = mergeObjects({
      // Config defaults
      attributeDefaultText: ATTRIBUTE_DEFAULT_TEXT,
      data: $node.data("fb-content-data"),
      editClassname: "active",
      id: $node.data("fb-content-id"),
      selectorDisabled: SELECTOR_DISABLED,
      text: {},
      type: $node.data("fb-content-type")
    }, config);

    $node.addClass("Question");
    this.editable = editableComponent($node, conf);
    this.$node = $node;
    this._config = conf;
  }

  data() {
    return this._config.data;
  }

  focus() {
    this.editable.focus();
  }

  save() {
    // TODO: Replace with proper mechanism to remove this workaround
    this.editable.save();
  }
}



module.exports = Question;
