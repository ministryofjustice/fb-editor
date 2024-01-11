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
 **/

const utilities = require("./utilities");
const mergeObjects = utilities.mergeObjects;
const Question = require("./question");

const SELECTOR_HINT = "fieldset > .govuk-hint";
const SELECTOR_LABEL = "legend > :first-child";
const SELECTOR_ITEM = ".govuk-radios__item";
const SELECTOR_ITEM_HINT = ".govuk-hint";
const SELECTOR_ITEM_LABEL = "label";

class RadiosQuestion extends Question {
  constructor($node, config) {
    let conf = mergeObjects(
      {
        // Add stuff here if you want to set defaults
        selectorLabel: SELECTOR_LABEL,
        selectorHint: SELECTOR_HINT,
        selectorCollectionItem: SELECTOR_ITEM,
        selectorComponentCollectionItemLabel: SELECTOR_ITEM_LABEL,
        selectorComponentCollectionItemHint: SELECTOR_ITEM_HINT,

        filters: {
          _id: function (index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          },
          value: function (index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          },
        },

        onCollectionItemClone: function ($node) {
          // @node is the collection item (e.g. <div> wrapping <input type=radio> and <label> elements)
          // Runs after the collection item has been cloned, so further custom manipulation can be
          // carried out on the element.
          $node.find("label").text(config.text.option);
          $node.find("span").text(config.text.optionHint);
        },
        onItemRemove: function (item) {
          // @item (EditableComponentItem) Item to be deleted.
          // Runs before removing an editable Collection item.
          // Provides an opportunity for clean up.
          var activatedMenu = item.$node.data("ActivatedMenu");
          if (activatedMenu) {
            activatedMenu.activator.$node.remove();
            activatedMenu.$node.remove();
            activatedMenu.container.$node.remove();
          }
        },
        onItemRemoveConfirmation: function (item) {
          // @item (EditableComponentItem) Item to be deleted.
          // Runs before onItemRemove when removing an editable Collection item.
        },
      },
      config,
    );
    super($node, conf);

    this.config = conf;
    this._preservedItemCount = 2;
    $node.addClass("RadiosQuestion");
    this.addAccessibleLabels();
  }

  addAccessibleLabels() {
    // We add this so that in the editor the text in the legend is not used as
    // the group label, as it gets confusing
    this.$node.find("fieldset > legend").attr("aria-label", "Question");

    // Similarly we add a group label for the answers section
    this.$node
      .find(".EditableComponentCollectionItem")
      .first()
      .parent()
      .attr("aria-label", this.config.text.aria.answers);

    // Add labels for each of the contentEditable checkbox <label> elements
    this.$node.find(".govuk-radios__label").each(function (index) {
      $(this).attr("aria-label", `Label for radio option ${index + 1}`);
    });

    // Add labels for the hint text elements for each option
    // Add the describedyby for optional content too
    this.$node.find(".govuk-radios__hint").each(function (index) {
      $(this).attr(
        "aria-label",
        `Optional hint text for radio option ${index + 1}`,
      );

      $(this).attr("aria-describedby", "optional_content_description");
    });
  }
}

module.exports = RadiosQuestion;
