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
const SELECTOR_LABEL = "legend > :first-child";
const SELECTOR_ITEM = ".govuk-radios__item";
const SELECTOR_ITEM_HINT = ".govuk-hint";
const SELECTOR_ITEM_LABEL = ".govuk-radios__label";
const SELECTOR_DISABLED = "input:not(:hidden)";

class RadiosQuestion extends Question {
  constructor($node, config) {
    // // When the labels are <label> elements they won't have an aria-label
    // // announced by Voiceover
    // $node.find(".govuk-radios__label").each(function () {
    //   changeTag(this, "div");
    // });
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
        afterItemRemove: function (items) {
          items.forEach(function (item, index) {
            item.$node
              .find(".govuk-radios__label")
              .attr("aria-label", `Label for option ${index + 1}`);
            item.$node
              .find(SELECTOR_DISABLED)
              .attr("aria-disabled", true)
              .attr("aria-label", `Answer option ${index + 1}`)
              .attr("aria-describedby", "disabled_input_description")
              .on("click", (e) => {
                e.preventDefault();
              });
            item.$node
              .find(".govuk-radios__hint")
              .attr("aria-label", `Optional hint text for option ${index + 1}`)
              .attr("aria-describedby", "optional_content_description");
            item.$node.find("button").text(`Edit option ${index + 1}`);
          });
        },
        onItemAdd: function ($node) {
          const index = $node.data("instance").component.items.length;
          $node
            .find(".govuk-radios__label")
            .attr("aria-label", `Label for option ${index}`);
          $node
            .find(SELECTOR_DISABLED)
            .attr("aria-disabled", true)
            .attr("aria-label", `Answer option ${index}`)
            .attr("aria-describedby", "disabled_input_description")
            .on("click", (e) => {
              e.preventDefault();
            });
          $node
            .find(".govuk-radios__hint")
            .attr("aria-label", `Optional hint text for option ${index}`)
            .attr("aria-describedby", "optional_content_description");
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
    // Similarly we add a group label for the answers section
    this.$node
      .find(".EditableComponentCollectionItem")
      .first()
      .parent()
      .attr("aria-role", "group")
      .attr("aria-label", this.config.text.aria.answers);

    // Add labels for each of the contentEditable checkbox <label> elements
    // remove 'for' attribute to prevent AT reading this for the field itself
    this.$node.find(".govuk-radios__label").each(function (index) {
      $(this)
        .attr("aria-label", `Label for option ${index + 1}`)
        .removeAttr("for");
    });

    // Provide labels with indexes for input options
    this.$node.find(SELECTOR_DISABLED).each(function (index) {
      $(this).attr("aria-label", `Answer option ${index + 1}`);
    });

    // Add labels for the hint text elements for each option
    // Add the describedyby for optional content too
    this.$node.find(".govuk-radios__hint").each(function (index) {
      $(this)
        .attr("aria-label", `Optional hint text for option ${index + 1}`)
        .attr("aria-describedby", "optional_content_description");
    });
  }
}

module.exports = RadiosQuestion;
