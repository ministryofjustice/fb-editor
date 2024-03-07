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

const { createElement, uniqueString } = require("../../utilities");

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

    if (!$node || $node.length < 1) {
      this.$node = this.#createNode();
    } else {
      this.$node = $node;
    }
    this.$node.data("instance", this);

    this.#addAttributes();
    this.#bindEventHandlers();
  }

  render() {
    if (this.menu.$parent.find(".flow-conditions").length) {
      this.$node.insertBefore(this.menu.$parent.find(".flow-conditions"));
    } else {
      this.menu.$parent.append(this.$node);
    }
  }

  /**
   * Creates a button element using config
   * @return {jQuery}
   */
  #createNode() {
    const $node = $(
      createElement(
        "button",
        this.#config.activator_text,
        this.#config.activator_classname,
      ),
    );
    console.log("creating activator");
    $node.attr('aria-label', this.#config.activator_text)
    $node.append(this.#icon());
    return $node;
  }

  #icon() {
    let icon;
    console.log(this.#config.activator_icon);
    switch (this.#config.activator_icon) {
      case "plus":
        icon = `<svg width="31" height="31" viewBox="0 0 31 31" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
            <polygon points="14,10 17,10 17,14 21,14 21,17 17,17 17,21 14,21 14,17 10,17 10,14 14,14 14,10"  fill="currentColor" />
        </svg>`;
        break;
      case "ellipsis":
      default:
        icon = `<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
    <circle cx="8.5" cy="16.5" r="2.5" fill="currentColor"/>
    <circle cx="16.5" cy="16.5" r="2.5" fill="currentColor"/>
    <circle cx="24.5" cy="16.5" r="2.5" fill="currentColor"/>
</svg>`;
        break;
    }
    console.log(icon);
    return icon;
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
    this.$node.on("mousedown.ActivatedMenuActivator", (event) => {
      this.menu.currentActivator = event.currentTarget;
      this.menu.open();
    });

    this.$node.on("focus", (event) => {
      this.$node.addClass("active");
    });

    this.$node.on("blur", (event) => {
      if (!this.menu.state.open) {
        this.$node.removeClass("active");
      }
    });

    this.$node.on("keydown", (event) => {
      let key = event.originalEvent.code;

      switch (key) {
        case "Enter":
        case "Space":
        case "ArrowDown":
          event.preventDefault();

          this.menu.currentActivator = event.currentTarget;
          this.menu.open();
          this.menu.focus();
          break;
        case "ArrowUp":
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
