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

const { mergeObjects, changeTag } = require("./utilities");
const Question = require("./question");

const SELECTOR_HINT = "fieldset > .govuk-hint";
const SELECTOR_LABEL = "legend > h1 span, legend > h2 span";
const SELECTOR_ITEM = ".govuk-radios__item";
const SELECTOR_ITEM_HINT = ".govuk-radios__hint";
const SELECTOR_ITEM_LABEL = ".govuk-radios__label";
const SELECTOR_DISABLED = "input:not(:hidden)";

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
        beforeItemRemove: function (item) {
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
        afterItemRemove: (items) => {
          items.forEach((item, index) => {
            this.updateItemAccessibleLabels(item.$node, index + 1);
          });
        },
        onItemAdd: ($node) => {
          const index = $node.data("instance").component.items.length;
          this.updateItemAccessibleLabels($node, index);
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
    // this.addAccessibleLabels();
  }

  addAccessibleLabels() {
    super.addAccessibleLabels();
    // Add a group label for the answers section
    this.$node.find(".EditableComponentCollectionItem").first().parent().attr({
      "role": "group",
      "aria-label": this.labels.answers,
    });

    // Update the labels for all of the items
    this.$node
      .find(SELECTOR_ITEM)
      .toArray()
      .forEach((item, index) => {
        this.updateItemAccessibleLabels($(item), index + 1);
      });
  }

  updateItemAccessibleLabels($node, index) {
    // Add labels for each of the contentEditable checkbox <label> elements
    // remove 'for' attribute to prevent AT reading this for the field itself
    $node
      .find(SELECTOR_ITEM_LABEL)
      .attr("aria-label", `${this.labels.items.label} ${index}`)
      .removeAttr("for");

    // Provide labels with indexes for input options
    $node
      .find(SELECTOR_DISABLED)
      .attr("aria-disabled", true)
      .attr("aria-label", `${this.labels.items.answer} ${index}`)
      .attr("aria-describedby", "disabled_input_description")
      .on("click", (e) => {
        e.preventDefault();
      });

    // Add labels for the hint text elements for each option
    // Add the describedyby for optional content too
    $node
      .find(SELECTOR_ITEM_HINT)
      .attr("aria-label", `${this.labels.items.hint} ${index}`)
      .attr("aria-describedby", "optional_content_description");

    // Add index to item three-dot button
    $node
      .find("button")
      .attr("aria-label", `${this.labels.items.menu_button} ${index}`);
  }
}

module.exports = RadiosQuestion;
