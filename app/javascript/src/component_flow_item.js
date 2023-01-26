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
    this.$node = $node;
    this.id = config.id;
    this.next = config.next;
    this.row = config.row;
    this.column = config.column;
    this.bounds = {
      x1: config.x_in,
      y1: config.y_in,
      x2: config.x_out,
      y2: config.y_out
    };

    this.position = {
      left: this.bounds.x1,
      top: this.bounds.y1,
    }

    $node.data("instance", this);
    $node.addClass("FlowItem");
    $node.attr('data-row', this.row);
  }
}



// Make available for importing.
module.exports = FlowItem;
