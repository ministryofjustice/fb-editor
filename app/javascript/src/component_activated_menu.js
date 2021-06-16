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
const safelyActivateFunction = utilities.safelyActivateFunction;


class ActivatedMenu {
  constructor($menu, config) {
    this._config = mergeObjects({ menu: {} }, config);
    this.$node = $menu;
    this.activator = new ActivatedMenuActivator(this, config);
    this.container = new ActivatedMenuContainer(this, config);

    this.position = mergeObjects({
      // Default position settings (can be set on instantiation or overide
      // on-the-fly by passing to component.open() function. Passing in a
      // position object will set the temporary value this.state.position.
      my: "left top",
      at: "left bottom",
      of: this.activator.$node
    }, property(config, "menu.position") );

    this.state = {
      open: false,
      position: null // Default is empty - update this dynamically by passing
                     // to component.open() - will be reset on component.close()
                     // See config.position (above) and jQueryUI documentation
                     // for what value(s) are required.
    }

    this.$node.menu(config.menu); // Bit confusing but is how jQueryUI adds effect to eleemnt.
    this.$node.addClass("ActivatedMenu_Menu");

    ActivatedMenu.bindMenuEventHandlers.call(this);
    ActivatedMenu.setMenuOpenPosition.call(this);

    this.close();
  }

  // Opens the menu.
  // @position (Object) Optional (jQuery position) object.
  open(position) {
    ActivatedMenu.setMenuOpenPosition.call(this, position);
    this.activator.$node.addClass("active");
    this.container.$node.show();
    this.state.open = true;
    this.$node.find(".ui-menu-item:first > :first-child").focus();
  }

  // Method
  close() {
    this.activator.$node.removeClass("active");
    this.container.$node.hide();
    this.state.open = false;

    // Reset any externally/temporary setting of
    // component.state.position back to default.
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
    // event.currentTarget will be the menu (UL) element.
    // check if relatedTarget is not a child element.
    component.state.close = true;
    if(!$.contains(event.currentTarget, event.relatedTarget)) {
      setTimeout(function(e) {
        if(component.state.close) {
          component.close();
        }
      }, 250);
    }
  });

  this.$node.on("mouseover", (event) => {
    component.state.close = false;
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
 * Positions the menu in relation to the activator  if received
 * a setting in passed configuration (this._config.position).
 * Uses the jQueryUI position() utility function to set the values.
 **/
ActivatedMenu.setMenuOpenPosition = function(position) {
  var pos = position || {};
  this.container.$node.position({
    my: (pos.my || this.position.my),
    at: (pos.at || this.position.at),
    of: (pos.of || this.position.of)
  });
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
  this.state.position = null; // Reset because this one is set on-the-fly
}


class ActivatedMenuContainer {
  constructor(menu, config) {
    var $node = $(createElement("div", "", "ActivatedMenu_Container"));

    if(config.container_id) {
      $node.attr("id", config.container_id);
    }

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
  }
}


class ActivatedMenuActivator {
  constructor(menu, config) {
    var $node = config.activator;
    if(!$node || $node.length < 1) {
      $node = $(createElement("button", config.activator_text, config.activator_classname));
    }

    $node.on("click.ActivatedMenuActivator", (event) => {
      menu.state.activator = event.currentTarget;
      menu.open();
    });

    $node.on("focus", (e) => {
      $node.addClass("active");
    });

    $node.on("blur", (e) => {
      if(!menu.state.open) {
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

    this.$node = $node;
    this.menu = menu;
  }
}


// Make available for importing.
module.exports = ActivatedMenu;

