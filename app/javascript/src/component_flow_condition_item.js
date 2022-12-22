/**
 * FlowConditionItem Component
 * ----------------------------------------------------
 *
 * Description:
 * Creates a flow condition item from HTML in source.
 * Expected use within a Form Overvew but should not be tied to a view.
 *
 * Documentation:
 *
 *     - TODO:
 *       https://ministryofjustice.github.io/moj-forms-tech-docs/documentation/services/editor/javascript/component-flow-condition-item.html
 *
 **/




/* FlowConditionItem component
 * ---------------------------
 * Simple item to mimic FlowItem-like object but for the branch conditions.
 * Could also be renamed FlowBranchCondition class but we're trying to
 * highlight the similarities to a FlowItem (which could also be split into
 * two separate classes of FlowPage and FlowBranch but keeping things simple).
 *
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class FlowConditionItem {
  constructor($node, config) {
    $node.data("instance", this);
    $node.addClass("FlowConditionItem");

    this.$node = $node;
    this.$from = config.$from;
    this.$next = config.$next;
    this.row = config.row;
    this.column = config.column;
    this.bounds = {
      x1: config.x_in,
      y1: config.y_in,
      x2: config.x_out,
      y2: config.y_out
    };
  }
}


// Make available for importing.
module.exports = FlowConditionItem;
