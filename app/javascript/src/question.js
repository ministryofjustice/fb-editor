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


import { safelyActivateFunction, mergeObjects, updateHiddenInputOnForm } from './utilities';
import { ActivatedMenu } from './component_activated_menu';


class Question {
  constructor($node, config) {
    var conf = mergeObjects({
      data: {},
      property_menu_activator_text: "",
      property_menu_target_selector: "",
      property_menu_template: "<ul></ul>"
    }, config);

    $node.addClass("Question");
    console.log("Question data: ", conf.data);


    // Add Question property menus
    let menu = new QuestionMenu($(conf.property_menu_template), {
      required: false, // Should have some data from server, fed in from somewhere, to give us this information.
      activator_text: conf.property_menu_activator_text,
      question_data: conf.data
    });

    $(document.body).append(menu.$node);
    $(conf.property_menu_target_selector, $node).before(menu.activator.$node);

    this.$node = $node;
    this.menu = menu;
    this._config = conf;
  }

  get data() {
    return this._config.data;
  }

  set data(data) {
    // TODO: What?
    // this._config.data = data;
  }
}


/* Controls form step add/edit/delete/preview controls
 **/
class QuestionMenu {
  constructor($node, config) {
    var conf = mergeObjects({
      container_classname: "QuestionMenu",
      activator_classname: $node.data("activator-classname"),
      container_id: $node.data("activated-menu-container-id"),
      activator_text: "",
      question_data: {}
    }, config);
console.log("$node: ", $node);
    $node.on("menuselect", QuestionMenu.selection.bind(this) );

    this.menu = new ActivatedMenu($node, conf);
    this.activator = this.menu.activator;
    this._config = conf;
  }

  get required() {
    // TODO: (perhaps... just thinking it through right now)
    // 1. Create a dialog box for property
    // 2. Populate dialog box with relevant content and settings (including errors if return visit)
    // 3. Open dialog box
    console.log("get required setting");
    console.log("properties: ", app.page.properties);
    console.log("data: ", this._config.question_data);
  }

  set required(settings) {
     // TODO: (perhaps... just thinking it through right now)
     // 1. Close dialog box
     // 2. Store/update/send settings ??
     // 3. Delete dialog box
     console.log("set required setting");
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


export { Question }
