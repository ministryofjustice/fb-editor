/**
 * Dialog Component
 * ----------------------------------------------------
 * Description:
 * Creates an area that expands and contracts, activated by a single element.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

const utilities = require('./utilities');


/* Main class
 * Select an element that should show/hide its content based on activator toggle.
 * The component will inject a container that wraps the elements content.
 * An activator will be created, if not specified, and moved to be placed just
 * before the injected container element. Toggle of the activator will show/hide
 * the content, which is now wrapped by the injected container.
 *
 * @$node  (jQuery node) Element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class Expander {
  constructor($node, config) {
    var conf = utilities.mergeObjects({
      activator_text: "Toggle", // Text for any self-created activator button.
      auto_open: false, // Set whether open on creation.
      duration: 0, // Number determining how long the animation will run
      $activator: null // Pass in the jQuery element you want to toggle open/close.
    }, config);

    var id = utilities.uniqueString("Expander_");
    var $children = $node.children();
    var $container = $("<div></div>");

    $container.attr("id", id);
    $container.addClass("Expander_container");
    $node.addClass("Expander");

    this._config = conf;
    this.$node = $node;
    this.$container = $container;
    this.$activator = Expander.createActivator.call(this, $container);

    // A little accessibility
    this.$activator.attr("aria-controls", id);

    // Setup and initial state
    this.$container.append($children);
    this.$node.prepend(this.$container);
    this.$node.prepend(this.$activator);

    if(conf.auto_open) {
      this.open();
    }
    else {
      this.close();
    }
  }

  open() {
    this.$node.addClass("open");
    this.$container.slideDown({ duration: this._config.duration });
    this.$container.attr("aria-expanded", true);
    this._config.opened = true;
  }

  close() {
    this.$node.removeClass("open");
    this.$container.slideUp({ duration: this._config.duration });
    this.$container.attr("aria-expanded", false);
    this._config.opened = false;
  }

  toggle() {
    if(this.$container.attr("aria-expanded") == "true") {
      this.close();
    }
    else {
      this.open();
    }
  }
}

Expander.createActivator = function($container) {
  var conf = this._config;
  var $activator = conf.$activator || $("<button>" + conf.activator_text + "\</button>");
  $activator.addClass("Expander_Activator");
  $activator.css("cursor", "pointer");
  $activator.on("click", () => {
    this.toggle();
  });

  this.$node.prepend($activator);
  return $activator;
}



// Make available for importing.
module.exports = Expander;
