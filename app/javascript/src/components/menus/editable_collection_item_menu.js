
/**
 * Activated Editable Collection Item Menu Component
 * ----------------------------------------------------
 * Description:
 * Enhances Activated Menu component for specific Editable Collection Item Menu.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/menu
 *
 **/


const { mergeObjects } = require('../../utilities');
const ActivatedMenu = require('./activated_menu');


class EditableCollectionItemMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      activator_text: "",
      $target: $(), // Used in placing the activator
      collectionItem: {},
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

    this.container.$node.addClass("EditableCollectionItemMenu");
    this.collectionItem = config.collectionItem;
  }

  selection(event, item) {
    let action = item.data("action");
    this.selectedItem = item;

    event.preventDefault();
    switch(action) {
      case "remove":
        $(document).trigger("EditableCollectionItemMenuSelectionRemove", {
          selectedItem: item,
          collectionItem: this.collectionItem
        });
        break;
      case "close":
        this.close();
        break;
    }
  }

  close() {
    super.close();
    this.activator.$node.removeClass("active");
  }
}
module.exports = EditableCollectionItemMenu;
