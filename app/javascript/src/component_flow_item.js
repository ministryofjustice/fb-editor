/**
 * FlowItem Component
 * ----------------------------------------------------
 *
 * Description:
 * Creates a flow item from HTML in source.
 * Expected use within a Form Overvew but should not be tied to a view.
 *
 * Documentation:
 *
 *     - TODO:
 *       https://ministryofjustice.github.io/moj-forms-tech-docs/documentation/services/editor/javascript/component-flow-item.html
 *
 **/




/* FlowItem component
 * ------------------------
 * Positionable item expected within a Flow Layout.
 *
 * @$node  (jQuery node) Element found in DOM that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class FlowItem {
  constructor($node, config) {
    $node.data("instance", this);
    $node.addClass("FlowItem");

    this.$node = $node;
    this.id = config.id;
    this.next = config.next;
    this.row = config.row;
    this.column = config.column;
    this.coords = {
      x_in: config.x_in,
      x_out: config.x_out,
      y: config.y,
    };

  }
}



// Make available for importing.
module.exports = FlowItem;
