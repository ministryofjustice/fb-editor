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


import { safelyActivateFunction, mergeObjects, updateHiddenInputOnForm } from './utilities';
import { ActivatedMenu } from './component_activated_menu';


class QuestionMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      container_classname: "QuestionMenu",
      activator_text: "",
      $target: $(), // Used in placing the activator
      question: {}, // TODO: Not sure if we should do this way
      view: {}
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
  }

  get required() {
    var dialog = this._config.view.dialogConfiguration;
    var field_content = this._config.page_property_fields; // TODO: Expect this to change when we add more property fields
    var required = this.question.data.validation.required;
    var regex = new RegExp("(input.*name=\"required\".*value=\"" + required + "\")", "mig");
    field_content = field_content.replace(regex, "$1 checked=\"true\"")
    dialog.configure({
      content: field_content
    }, (content) => { this.required = content } );
  }

  set required(content) {
    var arr = content.find("form").serializeArray();
    for(var i=0; i < arr.length; ++i) {
      this.question.data.validation[arr[i].name] = arr[i].value;
    }
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



export { QuestionMenu }
