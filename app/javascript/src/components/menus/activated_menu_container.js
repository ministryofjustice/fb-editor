const {
  createElement,
} = require('../../utilities');

class ActivatedMenuContainer {
  constructor(menu, config) {
    var $node = $(createElement("div", "", "ActivatedMenu_Container"));

    $node.attr("id", config.container_id);
    if(config.container_classname) {
      $node.addClass(config.container_classname);
    }

    // Allow component public functions to be triggered from the jQuery object without
    // jumping through all the hoops of creating/using a jQuery widget.
    // e.g. use $("#myMenuContainerNode").trigger("component.open")
    // TODO: Are these still needed? CP 29/03/2022
    $node.on("component.open", (event, position) => menu.open(position) );
    $node.on("component.close", () => menu.close() );

    // Add Container to DOM then put the menu inside it.
    // Lastly, move to just inside body for z-index reasons.
    menu.$node.before($node);
    $node.append(menu.$node);
    $(document.body).append($node);

    this.$node = $node;
    this.$node.data("instance", this);
    this.menu = menu;
  }
}
module.exports = ActivatedMenuContainer;
