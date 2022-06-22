/**
 * Activated Menu Activator
 * ----------------------------------------------------
 * Description
 * Adds behaviour to activated an Activated Menu.  Can either be passed an
 * element to enhance as part of the config, or will create and insert a
 * <button> element.
 *
 * Configuration
 * The constructor object accept the same configuration object as an Activated
 * Menu.  The relevant keys are:
 *  - activator (jQuery) object that will be enhanced into an
 *                       ActivatedMenuActivator.  If none is provided, an element
 *                       will be created and inserted.
 *  - activator_classname (string) class(es) to be added to the created activator
 *  - activator_text (string) accessible label for the created activator element
 *
 **/

const {
  createElement,
  uniqueString
} = require('../../utilities');

class ActivatedMenuActivator {
  #config;
  #className;

  /**
   * @param {ActivatedMenu} the menu instance to be activated
   * @param {object} ActivatedMenu configuration object 
   */
  constructor(menu, config) {
    let $node = config.activator;
    this.#config = config;
    this.#className = "ActivatedMenuActivator";
    this.menu = menu;
    this.$node = this.#insertNode($node);
    this.$node.data("instance", this);
    
    this.#addAttributes();
    this.#bindEventHandlers();
  }

   /**
    * Inserts the activator button into the DOM before the menu
    * if $node is not provided it will be created
    * @param {jQuery|undefined} $node jquery node for the button
    * @return {jQuery} button node 
    */
  #insertNode($node) {
    if(!$node || $node.length < 1) {
      $node = this.#createNode();
    }
    this.menu.$node.before($node);

    return $node;
  }

   /**
    * Creates a button element using config
    * @return {jQuery} 
    */
  #createNode() {
      const $node = $(
        createElement("button", 
                      this.#config.activator_text, 
                      this.#config.activator_classname
        )
      );
      return $node;
  }

  #addAttributes() {
    this.$node.addClass(this.#className);
    this.$node.attr("type", "button");
    this.$node.attr("id", uniqueString("menuActivator"));
    this.$node.attr("aria-haspopup", "menu");
    this.$node.attr("aria-controls", this.#config.container_id);
    this.menu.$node.attr("aria-labelledby", this.$node.attr("id"));
  }

  #bindEventHandlers() {
    this.$node.on("click.ActivatedMenuActivator", (event) => {
      this.menu.currentActivator = event.currentTarget;
      this.menu.open();
    });

    this.$node.on("focus", (event) => {
      this.$node.addClass("active");
    });

    this.$node.on("blur", (event) => {
      if(!this.menu.state.open) {
        this.$node.removeClass("active");
      }
    });

    this.$node.on("keydown", (event) => {
      let key = event.originalEvent.code;
      
      switch(key) {
        case 'Enter':
        case 'Space':
        case 'ArrowDown':
          event.preventDefault();

          this.menu.currentActivator = event.currentTarget;
          this.menu.open();
          this.menu.focus();
          break;
        case 'ArrowUp':
          event.preventDefault();

          this.menu.currentActivator = event.currentTarget;
          this.menu.open(); 
          this.menu.focusLast();
          break;
      }
    });
  }
}
module.exports = ActivatedMenuActivator;
