/**
 * Activated Menu Component
 * ----------------------------------------------------
 * Description:
 * Enhances jQueryUI Menu component by adding a controlling activator.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/menu
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

const utilities = require('./utilities');
const property = utilities.property;
const mergeObjects = utilities.mergeObjects;
const createElement = utilities.createElement;
const uniqueString = utilities.uniqueString;


class ActivatedMenu {
  constructor($menu, config) {
    if(!config.container_id) {
      config.container_id = uniqueString("menu");
    }

    this.$node = $menu;
    this._config = mergeObjects({ menu: {} }, config);
    this.activator = new ActivatedMenuActivator(this, config);
    this.container = new ActivatedMenuContainer(this, config);

    this._position = mergeObjects({
      // Default position settings (can be set on instantiation or overide
      // on-the-fly by passing to component.open() function. Passing in a
      // position object will set the temporary value this._state.position.
      my: "left top",
      at: "left bottom",
      of: this.activator.$node
    }, property(config, "menu._position") );

    this._state = {
      open: false,
      position: null // Default is empty - update this dynamically by passing
                     // to component.open() - will be reset on component.close()
                     // See _private.position (above) and jQueryUI documentation
                     // for what value(s) are required.
    }

    this.connectedSecondaryMenu = config.connectedSecondaryMenu; // A way to bridge across different component menus
    this.container.$node.addClass("ActivatedMenu"); // Also add the main component class.
    this.$node.menu(config.menu); // Bit confusing but is how jQueryUI adds effect to eleemnt.
    this.$node.addClass("ActivatedMenu_Menu");
    this.$node.data("instance", this); // Add reference for instance from original node.
    this.container.$node.css("width", this.$node.width() + "px"); // Required for alternative positioning.

    ActivatedMenu.bindMenuEventHandlers.call(this);
    ActivatedMenu.setMenuOpenPosition.call(this);

    this.close();
  }

  get connectedSecondaryMenu() {
    return this._connectedSecondaryMenu;
  }

  set connectedSecondaryMenu(menu) {
    this._connectedSecondaryMenu = menu;
  }

  isOpen() {
    return this._state.open;
  }

  // Opens the menu.
  // @position (Object) Optional (jQuery position) object.
  open(position) {
    if(position) {
      // Use the passed postion values, without question.
      ActivatedMenu.setMenuOpenPosition.call(this, position);
    }
    else {
      // Try to use the default position values, which will
      // also attempt to figure out if there's enough room
      // for the menu to show on the right of the screen.
      // If there's not, it will try to reverse things.
      // Note: The underlying jQueryUI menu widget should
      //       be able to do this but we have a wrapper
      //       element on our menu (see container.$node).
      //       We have to manually move the container to
      //       set the desired position.
      ActivatedMenu.calculateMenuOpenPosition.call(this);
    }

    this.container.$node.position(this._state.position);
    this.container.$node.show();
    this.$node.find(".ui-menu-item:first > :first-child").focus();
    this.activator.$node.addClass("active");
    this.activator.$node.attr("aria-expanded", true);
    this._state.open = true;
  }

  // Method
  close() {
    this._state.open = false;
    this.container.$node.hide();
    this.activator.$node.removeClass("active");
    this.activator.$node.attr("aria-expanded", false);

    // Reset any externally/temporary setting of
    // component._state.position back to default.
    ActivatedMenu.resetMenuOpenPosition.call(this);
  }
}

/* Private function
 * All the event handlers that would otherwse clutter up the
 * constructor of ActivatedMenu.
 **/
ActivatedMenu.bindMenuEventHandlers = function() {
  var component = this;

  // Main (generated) activator uses this event to
  // open the menu.

  this.$node.on("mouseout", (event) => {
    var connectedMenu = this.connectedSecondaryMenu;
    component._state.close = true;

    // IF the mouse is no longer over any part of the menu.
    // !$.contains(event.currentTarget, event.relatedTarget)
    //
    // AND it does not have a connected menu
    // !connectedMenu
    //
    // OR a connected menu is not open
    // !connectedMenu.isOpen()
    if(!$.contains(event.currentTarget, event.relatedTarget) && (!connectedMenu || !connectedMenu.isOpen())) {
      setTimeout(function(e) {
        if(component._state.close) {
          component.close();
        }
      }, 250);
    }
  });

  this.$node.on("mouseover", (event) => {
    component._state.close = false;
  });


  // Add a trigger for any listening document event
  // to activate on menu item selection.
  if(this._config.selection_event) {
    let component = this;
    component.$node.on("menuselect", function(event, ui) {
      var e = event.originalEvent;

      if(component._config.preventDefault) {
         e.preventDefault();
      }

      $(document).trigger(component._config.selection_event, {
        activator: ui.item,
        menu: event.currentTarget,
        component: component,
        original: {
          element: e.target,
          event: e
        }
      });
    });
  }
}

/* Private function
 * Sets the menu position to the passed setting or uses the
 * default setting (which can also be changed in constructor
 * by passing in configuration at instantiation time.
 *
 * Uses the jQueryUI position() utility function for the
 * values to set.
 * e.g. @position (Object) {
 *                           my: "left top",
 *                           at: "left bottom",
 *                           of: some_element_here
 *                         }
 **/
ActivatedMenu.setMenuOpenPosition = function(position) {
  var pos = position || {};
  this._state.position = {
    my: (pos.my || this._position.my),
    at: (pos.at || this._position.at),
    of: (pos.of || this._position.of)
  }
}

/* Private function
 * Positions the menu in relation to the activator and default
 * position values, but tries to calculate if needs to reverse
 * the open position based on if the activator is too far right.
 **/
ActivatedMenu.calculateMenuOpenPosition = function() {
  var activatorLeft = this.activator.$node.offset().left;
  var rightBoundary = window.innerWidth;
  var menuWidth = this.$node.outerWidth();

  if(rightBoundary - activatorLeft < menuWidth) {
    ActivatedMenu.setMenuOpenPosition.call(this, {
      my: "right top",
      at: "right bottom",
      of: this.activator.$node
    });
  }
  else {
    ActivatedMenu.setMenuOpenPosition.call(this);
  }
}

/* Private function
 * Removes any position values that have occurred as a result of
 * calling the setMenuOpenPosition() function.
 * Note: This assumes that no external JS script is trying to 
 * set values independently of the ActivatedMenu class functionality.
 * Clearing the values is required to stop jQueryUI position()
 * functionality adding to existing, each time it's called.
 * An alternative might be to set position once, and not on each 
 * ActivatedMenu.open call. There is a minor performance gain that
 * could be claimed, but it would also be less flexible, if the 
 * activators (used for position reference) need to be dynamically
 * moved for any enhance or future design improvements. 
 **/
ActivatedMenu.resetMenuOpenPosition = function() {
  var node = this.container.$node.get(0);
  node.style.left = "";
  node.style.right = "";
  node.style.top = "";
  node.style.bottom = "";
  node.style.position = "";
  this._state.position = null; // Reset because this one is set on-the-fly
}


class ActivatedMenuContainer {
  constructor(menu, config) {
    var $node = $(createElement("div", "", "ActivatedMenu_Container"));

    $node.attr("id", config.container_id);
    if(config.container_classname) {
      $node.addClass(config.container_classname);
    }

    // Allow component public functions to be triggered from the jQuery object without
    // jumping through all the hoops of creating/using a jQuery widget.
    // e.g. use  $("blah").trigger("component.open")
    $node.on("component.open", (event, position) => menu.open(position) );
    $node.on("component.close", (event, position) => menu.open(position) );

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


class ActivatedMenuActivator {
  constructor(menu, config) {
    var $node = config.activator;

    if(!$node || $node.length < 1) {
      $node = $(createElement("button", config.activator_text, config.activator_classname));
      $node.attr("type", "button");
    }

    $node.on("click.ActivatedMenuActivator", (event) => {
      menu._state.activator = event.currentTarget;
      menu.open();
    });

    $node.on("focus", (e) => {
      $node.addClass("active");
    });

    $node.on("blur", (e) => {
      if(!menu._state.open) {
        $node.removeClass("active");
      }
    });

    $node.on("keydown", (e) => {
      // TODO: Add more for keyboard support
      // console.log("e.which: , ", e.which);

      // ESC
      if(e.which == 27) {
        menu.close();
      }

      // DOWN
      if(e.which == 40) {
        menu.open();
      }

    });

    menu.$node.before($node);
    $node.addClass("ActivatedMenu_Activator");
    $node.attr("aria-haspopup", "menu");
    $node.attr("aria-controls", config.container_id);

    this.$node = $node;
    this.$node.data("instance", this);
    this.menu = menu;
  }
}


// Make available for importing.
module.exports = ActivatedMenu;

