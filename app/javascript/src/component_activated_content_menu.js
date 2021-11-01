/**
 * Activated Content Menu Component
 * ----------------------------------------------------
 * Description:
 * Enhances Activated Menu component for specific Content Property Menu.
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


class ContentMenu extends ActivatedMenu {
  constructor(component, $node, config) {
    super($node, mergeObjects({
      container_classname: "ContentMenu",
      activator_text: ""
    }, config));

    $node.on("menuselect", ContentMenu.selection.bind(this) );

    if(component.$node.length) {
      component.$node.prepend(this.activator.$node);
      component.$node.on("focus.contentmenu", () => this.activator.$node.addClass("active"));
      component.$node.on("blur.contentmenu", () => this.activator.$node.removeClass("active"));
    }

    this.container.$node.addClass("ContentMenu");
    this.component = component;
  }

  open(position) {
    if(this.component) {
      this.component.$node.addClass("active");
    }
    super.open(position);
  }

  close() {
    if(this.component) {
      this.component.$node.removeClass("active");
    }
    super.close();
  }

  remove() {
    $(document).trigger("ContentMenuSelectionRemove", this.component);
  }
}

/* Handles what happens when an item in the menu has been selected
 * @event (jQuery Event Object) See jQuery docs for info.
 * @data  (Object) See ActivatedMenu and search for config.selection_event
 **/
ContentMenu.selection = function(event, ui) {
  var action = $(event.originalEvent.currentTarget).data("action");
  safelyActivateFunction(this[action].bind(this));
}


module.exports = ContentMenu;
