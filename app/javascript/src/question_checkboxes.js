/**
 * Date Question
 * ----------------------------------------------------
 * Description:
 * Checkbox component extension of Question
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
const safelyActivateFunction = utilities.safelyActivateFunction;
const createElement = utilities.createElement;
const uniqueString = utilities.uniqueString;
const Question = require('./question');
const ActivatedMenu = require('./component_activated_menu');
const editableComponent = require('./editable_components');

const SELECTOR_HINT = "fieldset > .govuk-hint";
const SELECTOR_LABEL = "legend > :first-child";
const SELECTOR_ITEM = ".govuk-checkboxes__item";
const SELECTOR_ITEM_HINT = ".govuk-hint";
const SELECTOR_ITEM_LABEL = "label";


class CheckboxesQuestion extends Question {
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
        // This adjust the view to wrap Remove button with desired menu component.
        //
        // This is not very good but expecting it to get significant rework when
        // we add more menu items (not for MVP).
        collectionItemControlsInActivatedMenu($node, {
          activator_text: config.text.edit,
          classnames: "editableCollectionItemControls"
        });
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


    // If any Collection items are present with ability to be removed, we need
    // to find them and scoop up the Remove buttons to put in menu component.
    $(".EditableComponentCollectionItem").each(function() {
      collectionItemControlsInActivatedMenu($(this), {
       activator_text: config.text.edit,
        classnames: "editableCollectionItemControls"
      });
    }).parent().attr("aria-label", config.text.aria.answers);

    $node.addClass("CheckboxesQuestion");
    this._preservedItemCount = 1;
  }
}



/* Finds elements to wrap in Activated Menu component.
 * Best used for dynamically generated elements that have been injected into the page
 * through JS enhancement. If items existed in the template code, you could probably
 * just use an easier method such as applyMenus() function.
 *
 * This function will basically find desired elments, wrap each one with an <li> tag,
 * add those to a new <ul> element, and then create an ActivateMenu component from
 * that structure.
 *
 * @selector (String) jQuery compatible selector to find elements for menu inclusion.
 * @$node  (jQuery node) Wrapping element/container that should hold the elements sought.
 * effects and wraps them with the required functionality.
 **/
function collectionItemControlsInActivatedMenu($item, config) {
  var $elements = $(".EditableCollectionItemRemover", $item);
  if($elements.length) {
    $elements.wrapAll("<ul class=\"govuk-navigation\"></ul>");
    $elements.wrap("<li></li>");
    let menu = new ActivatedMenu($elements.parents("ul"), {
      activator_text: config.activator_text,
      container_classname: config.classnames,
      container_id: uniqueString("activatedMenu-"),
      menu: {
        position: { my: "left top", at: "right-15 bottom-15" } // Position second-level menu in relation to first.
      }
    });

    $item.data("ActivatedMenu", menu);
  }
}


module.exports = CheckboxesQuestion;
