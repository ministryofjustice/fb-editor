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
 **/
const {
  safelyActivateFunction,
  mergeObjects
} = require('../../utilities');
const ActivatedMenu = require('./activated_menu');

class ContentMenu extends ActivatedMenu {
  constructor(component, $node, config) {
    super($node, mergeObjects({
      container_classname: "ContentMenu",
      activator_text: ""
    }, config));

    $node.on("menuselect", (event,ui) => {
        this.selection(event, ui.item);
    });

    if(component.$node.length) {
      component.$node.prepend(this.activator.$node);
      component.$node.on("focus.contentmenu", () => this.activator.$node.addClass("active"));
      component.$node.on("blur.contentmenu", () => this.activator.$node.removeClass("active"));
    }

    this.container.$node.addClass("ContentMenu");
    this.component = component;
  }

  selection(event, item) {
    var action = item.data("action");
    this.selectedItem = item;

    event.preventDefault();
    switch(action) {
      case "open":
        this.open();
      case "remove":
        this.remove();
        break;
      case "close":
        this.close();
        break;
      case "conditional-content":
        this.conditionalContent(item);
        break;
    }
  }

  open(config) {
    if(this.component && this.component.state) {
      this.component.state.mode = 'edit'
    }
    super.open(config);
  }

  close() {
    if(this.component) {
      this.component.$node.removeClass("active");
    }
    super.close();
    this.activator.$node.removeClass("active");
  }

  remove() {
    $(document).trigger("ContentMenuSelectionRemove", this.component);
  }

  conditionalContent(item) {
    this.component.apiUrl = item.data('apiPath')
    console.log(this.component.apiUrl)
    $(document).trigger("ContentMenuSelectionConditionalContent", { component: this.component, selectedItem: item });
  }
}

module.exports = ContentMenu;
