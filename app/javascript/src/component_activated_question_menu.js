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


const utilities = require('./utilities');
const safelyActivateFunction = utilities.safelyActivateFunction;
const mergeObjects = utilities.mergeObjects;
const ActivatedMenu = require('./component_activated_menu');


class QuestionMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      activator_text: "",
      $target: $(), // Used in placing the activator
      question: {}, // TODO: Not sure if we should do this way
      view: {},
      onSetRequired: function(){} // Called at end of set required function
    }, config));

    $node.on("menuselect", QuestionMenu.selection.bind(this) );

    let $target = this._config.$target;
    if($target.length) {
      $target.before(this.activator.$node);
      $target.on("focus.questionmenu", () => this.activator.$node.addClass("active"));
      $target.on("blur.questionmenu", () => this.activator.$node.removeClass("active"));
    }

    this.container.$node.addClass("QuestionMenu");
    this.question = config.question;
    this.setRequiredViewState();
  }

  remove() {
    $(document).trigger("QuestionMenuSelectionRemove", this.question);
  }

  required() {
    $(document).trigger("QuestionMenuSelectionRequired", this.question);
  }

  /* Change required option state for view purpose
   **/
  setRequiredViewState() {
    if(this.question.data.validation.required) {
      $("[data-action=required]").addClass("on");
    }
    else {
      $("[data-action=required]").removeClass("on");
    }
  }
}

/* Handles what happens when an item in the menu has been selected
 * @event (jQuery Event Object) See jQuery docs for info.
 * @data  (Object) See ActivatedMenu and search for config.selection_event
 **/
QuestionMenu.selection = function(event, ui) {
  var action = $(event.originalEvent.currentTarget).data("action");
  safelyActivateFunction(this[action].bind(this));
}


module.exports = QuestionMenu;
