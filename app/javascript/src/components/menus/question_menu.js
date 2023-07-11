/**
 * Activated Question Menu Component
 * ----------------------------------------------------
 * Description:
 * Enhances Activated Menu component for specific Question Property Menu.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/menu
 *
 **/
const { mergeObjects }  = require('../../utilities');
const ActivatedMenu = require('./activated_menu');


class QuestionMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      activator_text: "",
      $target: $(), // Used in placing the activator
      question: {}, // TODO: Not sure if we should do this way
      view: {},
      onSetRequired: function(){} // Called at end of set required function
    }, config));

    $node.on("menuselect", (event, ui) => {
      this.selection(event, ui.item);
    });

    let $target = this.config.$target;
    if($target.length) {
      $target.before(this.activator.$node);
      $target.on("focus.questionmenu", () => this.activator.$node.addClass("active"));
      $target.on("blur.questionmenu", () => this.activator.$node.removeClass("active"));
    }

    this.container.$node.addClass("QuestionMenu");
    this.question = config.question;
    this.setEnabledValidations();
  }

  selection(event, item) {
    var action = item.data("action");
    this.selectedItem = item;

    event.preventDefault();
    switch(action) {
      case "remove":
           this.remove();
           break;
      case "required":
          this.required();
          break;
      case "validation":
        this.validation(item);
        break;
      case "upload":
        this.upload();
        break;
      case "multiupload":
        this.multiupload();
        break;
      case "close":
        this.close();
        break;
    }
  }

  // will raise a new event for multi upload
  remove() {
    $(document).trigger("QuestionMenuSelectionRemove", this.question);
  }

  required() {
    $(document).trigger("QuestionMenuSelectionRequired", this.question);
  }

  validation(menuItem) {
    var validation = menuItem.data("validation");
    $(document).trigger("QuestionMenuSelectionValidation", { question: this.question, validation: validation });
  }

  upload() {
    $(document).trigger("QuestionMenuSelectionUpload", this.question);
  }

  multiupload() {
    $(document).trigger("QuestionMenuSelectionMultiUpload", this.question);
  }

  close() {
    super.close();
    this.activator.$node.removeClass("active");
  }

  setEnabledValidations() {
    var validationData = Object.assign( {}, this.question.data.validation ); // don't mutate the question data

    if(validationData.hasOwnProperty('min_length') || validationData.hasOwnProperty('min_word') ){
      validationData.min_string_length = true;
    }

    if(validationData.hasOwnProperty('max_length') || validationData.hasOwnProperty('max_word') ){
      validationData.max_string_length = true;
    }

    this.$node.find("[data-validation]").each(function() {
      var validationType = $(this).data('validation');
      if( validationType == 'max_files' ) {
        return
      }
      
      if( validationData[validationType] ) {
        $(this).find('> :first-child').attr('aria-checked', 'true');
      } else {
        $(this).find('> :first-child').attr('aria-checked', 'false');
      }
    });
  }

}
module.exports = QuestionMenu;
