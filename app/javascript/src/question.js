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


const { mergeObjects }  = require('./utilities');
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

  get validation() {
    return this.data.validation;
  }

  set validation(data) {
    Object.keys(data).forEach( (validationType) => {
        if(data[validationType] == '') {
          delete this.data.validation[validationType];
        } else {
          this.data.validation[validationType] = data[validationType];
        }
    });
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
