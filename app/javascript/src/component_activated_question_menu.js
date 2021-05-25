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
const updateHiddenInputOnForm = utilities.updateHiddenInputOnForm;
const ActivatedMenu = require('./component_activated_menu');


class QuestionMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      container_classname: "QuestionMenu",
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

    // TODO: Perhaps this should simply be separate data record of some type.
    this.question = this._config.question.$node.data("instance");

    QuestionMenu.setRequiredViewState.call(this);
  }

  get required() {
    var dialog = this._config.view.dialogConfiguration;
    var field_content = this._config.question_property_fields; // TODO: Expect this to change when we add more property fields
    var required = this.question.data.validation.required;
    var regex = new RegExp("(input.*name=\"required\".*value=\"" + required + "\")", "mig");
    field_content = field_content.replace(regex, "$1 checked=\"true\"");
    dialog.configure({
      content: field_content
    }, (content) => { this.required = content } );
  }

  set required(content) {
    var arr = content.find("form").serializeArray();
    for(var i=0; i < arr.length; ++i) {
      this.question.data.validation[arr[i].name] = (arr[i].value == "true" ? true : false);
    }
    QuestionMenu.setRequiredViewState.call(this);
    safelyActivateFunction(this._config.onSetRequired, this);
  }
}

/* Handles what happens when an item in the menu has been selected
 * @event (jQuery Event Object) See jQuery docs for info.
 * @data  (Object) See ActivatedMenu and search for config.selection_event_node
 **/
QuestionMenu.selection = function(event, ui) {
  var action = $(event.originalEvent.currentTarget).data("action");
  safelyActivateFunction(this[action]);
}


/* Change required option state for view purpose
 **/
QuestionMenu.setRequiredViewState = function() {
  if(this.question.data.validation.required) {
    $("[data-action=required]").addClass("on");
  }
  else {
    $("[data-action=required]").removeClass("on");
  }
}



module.exports = QuestionMenu;
