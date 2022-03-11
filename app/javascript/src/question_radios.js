/**
 * Radios Question
 * ----------------------------------------------------
 * Description:
 * Radio component extension of Question
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


const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const Question = require('./question');

const SELECTOR_HINT = "fieldset > .govuk-hint";
const SELECTOR_LABEL = "legend > :first-child";
const SELECTOR_ITEM = ".govuk-radios__item";
const SELECTOR_ITEM_HINT = ".govuk-hint";
const SELECTOR_ITEM_LABEL = "label";


class RadiosQuestion extends Question {
  constructor($node, config) {
    super($node, mergeObjects({
      // Add stuff here if you want to set defaults
      selectorLabel: SELECTOR_LABEL,
      selectorHint: SELECTOR_HINT,
      selectorCollectionItem: SELECTOR_ITEM,
      selectorComponentCollectionItemLabel: SELECTOR_ITEM_LABEL,
      selectorComponentCollectionItemHint: SELECTOR_ITEM_HINT,

      filters: {
        _id: function(index) {
          return this.replace(/^(.*)?[\d]+$/, "$1" + index);
        },
        value: function(index) {
          return this.replace(/^(.*)?[\d]+$/, "$1" + index);
        }
      },

      onCollectionItemClone: function($node) {
         // @node is the collection item (e.g. <div> wrapping <input type=radio> and <label> elements)
         // Runs after the collection item has been cloned, so further custom manipulation can be
         // carried out on the element.
         $node.find("label").text(config.text.option);
         $node.find("span").text(config.text.optionHint);
      },
      onItemAdd: function($node) {
        // @$node (jQuery node) Node (instance.$node) that has been added.
        // Runs after adding a new Collection item.
      },
      onItemRemove: function(item) {
        // @item (EditableComponentItem) Item to be deleted.
        // Runs before removing an editable Collection item.
        // Provides an opportunity for clean up.
        var activatedMenu = item.$node.data("ActivatedMenu");
        if(activatedMenu) {
          activatedMenu.activator.$node.remove();
          activatedMenu.$node.remove();
          activatedMenu.container.$node.remove();
        }
      },
      onItemRemoveConfirmation: function(item) {
        // @item (EditableComponentItem) Item to be deleted.
        // Runs before onItemRemove when removing an editable Collection item.
      }
    }, config));

    $node.addClass("RadiosQuestion");

    // If any Collection items are present with ability to be removed, we need
    // to find them and scoop up the Remove buttons to put in menu component.
    $(".EditableComponentCollectionItem").parent().attr("aria-label", config.text.aria.answers);

    this._preservedItemCount = 2;
  }
}

module.exports = RadiosQuestion;
