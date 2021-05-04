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

    if(this._config.$target.length) {
      $(this._config.$target, $node).before(this.activator.$node);
    }

    this.question = this._config.question;
  }

  get required() {
    // TODO: (perhaps... just thinking it through right now)
    // 1. Create a dialog box for property
    // 2. Populate dialog box with relevant content and settings (including errors if return visit)
    // 3. Open dialog box
    console.log("get required setting");

    var view = this._config.view;
    var elements = view.dialogConfiguration._elements;
    elements.heading.text(view.text.dialogs.page_property_required_message);
    elements.message.text("");
    this._config.view.dialogConfiguration.open();
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



export { QuestionMenu }
