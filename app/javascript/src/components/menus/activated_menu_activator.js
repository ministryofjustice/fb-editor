const {
  createElement,
  uniqueString
} = require('../../utilities');

class ActivatedMenuActivator {
  #config;
  #className;

  /**
   * 
   * @param {ActivatedMenu} the menu instance to be activated
   * @param {object} configuration object 
   */
  constructor(menu, config) {
    let $node = config.activator;
    this.#config = config;
    this.#className = "ActivatedMenu_Activator";
    this.menu = menu;
    this.$node = this.#insertNode($node);
    this.$node.data("instance", this);
    
    this.#addAttributes();
    this.#bindEventHandlers();
  }

   /**
    * Inserts the activator button into the DOM before the menu
    * if $node is not provided it will be created
    *
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
      let $node = $(createElement("button", this.#config.activator_text, this.#config.activator_classname));
      return $node;
  }

   /**
    * Enhance the DOM element to add all required classes and attributes
    */
  #addAttributes() {
    this.$node.addClass(this.#className);
    this.$node.attr("type", "button");
    this.$node.attr("id", uniqueString("menuActivator"));
    this.$node.attr("aria-haspopup", "menu");
    this.$node.attr("aria-controls", this.#config.container_id);
  }

  #bindEventHandlers() {
    this.$node.on("click.ActivatedMenuActivator", (event) => {
      this.menu._state.activator = event.currentTarget;
      this.menu.open({
        position: {
          at: "left top",
          my: "left top",
          of: this.$node,
        }
      });
    });

    this.$node.on("focus", (event) => {
      this.$node.addClass("active");
    });

    this.$node.on("blur", (event) => {
      if(!this.menu._state.open) {
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

          this.menu._state.activator = event.currentTarget;
          this.menu.open();
          this.menu.focus();
          break;
        case 'ArrowUp':
          event.preventDefault();

          this.menu._state.activator = event.currentTarget;
          this.menu.open(); 
          this.menu.focusLast();
          break;
      }
    });
  }
}
module.exports = ActivatedMenuActivator;
