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
 *     - TODO::
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const { 
  mergeObjects,
  filterObject,
}  = require('./utilities');
const editableComponent = require('./editable_components').editableComponent;
const  QuestionMenu = require('./components/menus/question_menu');

const ATTRIBUTE_DEFAULT_TEXT = "fb-default-text";
const SELECTOR_DISABLED = "input:not(:hidden), textarea";
const SELECTOR_LABEL_HEADING = "label h1, label h2, legend h1, legend h2";


class Question {
  constructor($node, config) {
    var $heading = $(SELECTOR_LABEL_HEADING, $node);
    var conf = mergeObjects({
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
      view: {}
    }, config);

    $node.addClass("Question");
    this._config = conf;
    this.data = $node.data("fb-content-data");
    this.$node = $node;
    this.$heading = $heading;
    this.editable = editableComponent($node, conf);
    this.menu = createQuestionMenu.call(this);

    // Check view state on element edit or interaction and set initial state.
    $heading.on("blur", this.setRequiredFlag.bind(this));
    this.setRequiredFlag();
  }

  get required() {
    return this.data.validation.required;
  }

  set required(content) {
    var arr = content.find("form").serializeArray();
    for(var i=0; i < arr.length; ++i) {
      this.data.validation[arr[i].name] = (arr[i].value == "true" ? true : false);
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
    data =  mergeObjects(data, config);
    // Remove keys with empty values 
    data = filterObject(data, ([_, val]) => val != '' ); 
  
    // Ensure we don't have conflicting min_length/word and max_length/word keys
    switch(validationName) {
      case 'min_length':
        data = filterObject(data, ([key, _]) => key != 'min_word');         
        break;
      case 'min_word':
        data = filterObject(data, ([key, _]) => key != 'min_length');  
        break;
      case 'max_length':
        data = filterObject(data, ([key, _]) => key != 'max_word');
      break;
      case 'max_word':
        data = filterObject(data, ([key, _]) => key != 'max_length');
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
    var $target = this.$heading;
    var text = this._config.text.optionalFlag;
    var regExpTextWithSpace = " " + text.replace(/(\(|\))/mig, "\\$1"); // Need to escape parenthesis for RegExp
    var textWithSpace =  " " + text;
    var re = new RegExp(regExpTextWithSpace + "$");

    // Since we always remove first we can add knowing duplicates should not happen.
    $target.text($target.text().replace(re, ""));
    if(!this.required) {
      $target.text($target.text() + textWithSpace);
    }

    // If we've changed the $target content, or the eitor has, we
    // need to check whether required flag needs to show, or not.
    $target.data("instance").update();
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
}


/* Create a menu for Question property editing.
 **/
function createQuestionMenu() {
  var question = this;
  var template = $("[data-component-template=QuestionMenu_"+question.data._uuid+"]");
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
      }
    }
  });
}



module.exports = Question;
