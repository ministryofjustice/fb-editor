/**
 * Activated Menu Container
 * ----------------------------------------------------
 * Description
 * Wraps an Activated Menu in a contiainer <div> used for positioning the menu.
 *
 * Configuration:
 * The constructor object accept the same configuration object as an Activated
 * Menu.  The relevant keys are:
 *  - container_id (string) an HTML id attribute to be applied to the generated
 *                          ActivatedMenuContainer element.  If none is provided
 *                          a unique id will be generated.
 *  - container_classname (string) class(es) to be applied to the generated menu
 *                                 container element
 *
 **/

const { createElement } = require('../../utilities');

class ActivatedMenuContainer {
  #config
  #className

  /**
   * @param {ActivatedMenu} the menu instance to be activated
   * @param {object} ActivatedMenu configuration object
   */
  constructor(menu, config) {
    this.#config = config;
    this.#className = "ActivatedMenuContainer";
    this.menu = menu;
    this.$node = $(createElement("div"));
    this.$node.data("instance", this);

    this.#addAttributes();
    this.#bindEventHandlers();
  }

  #addAttributes() {
    this.$node.attr("id", this.#config.container_id);
    this.$node.addClass(this.#className);
    if(this.#config.container_classname) {
      this.$node.addClass(this.#config.container_classname);
    }
    //this.$node.css("width", this.menu.$node.width() + "px"); // Required for alternative positioning.
  }

  // Add Container to DOM then put the menu inside it.
  // Lastly, move to just inside body for z-index reasons.
  render() {
    this.menu.$parent.append(this.$node);
    this.$node.append(this.menu.$node);
    $(document.body).append(this.$node);
  }

  #bindEventHandlers() {
    // Allow component public functions to be triggered from the jQuery object without
    // jumping through all the hoops of creating/using a jQuery widget.
    // e.g. use $("#myMenuContainerNode").trigger("component.open")
    this.$node.on("component.open", (event, position) => this.menu.open(position) );
    this.$node.on("component.close", () => this.menu.close() );
  }


}
module.exports = ActivatedMenuContainer;
