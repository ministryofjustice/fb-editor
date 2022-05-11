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
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
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
    this.setRequiredViewState();
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
        console.log('selected a validation');
        this.validation(item);
        break;
      case "close":
        this.close();
        break;
    }
  }

  remove() {
    $(document).trigger("QuestionMenuSelectionRemove", this.question);
  }

  required() {
    $(document).trigger("QuestionMenuSelectionRequired", this.question);
  }

  validation(menuItem) {
    console.log(menuItem);
    var validation = menuItem.data("validation");
    console.log(validation);
    $(document).trigger("QuestionMenuSelectionValidation", this.question, validation);
  }

  close() {
    super.close(); 
    this.activator.$node.removeClass("active");
  }

  /* Change required option state for view purpose
   **/
  setRequiredViewState() {
    if(this.question.data.validation.required) {
      this.$node.find("[data-action=required] > :first-child").attr("aria-checked", "true");
    }
    else {
      this.$node.find("[data-action=required] > :first-child").attr("aria-checked", "false");
    }
  }
}
module.exports = QuestionMenu; 
