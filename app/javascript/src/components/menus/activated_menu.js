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

const {
  property,
  mergeObjects,
  createElement,
  uniqueString
} = require('../../utilities');

const tabbable = require('tabbable');
const ActivatedMenuItem = require('./activated_menu_item');
const ActivatedMenuActivator = require('./activated_menu_activator');
const ActivatedMenuContainer = require('./activated_menu_container');

const ITEMS_SELECTOR = '> li';

class ActivatedMenu {
  constructor($menu, config) {
    if(!config.container_id) {
      config.container_id = uniqueString("menu");
    }

    this.$node = $menu;
    this._config = config;
    this.activator = new ActivatedMenuActivator(this, config);
    this.container = new ActivatedMenuContainer(this, config);
  
    this._position = mergeObjects({
      // Default position settings (can be set on instantiation or overide
      // on-the-fly by passing to component.open() function. Passing in a
      // position object will set the temporary value this._state.position.
      my: "left top",
      at: "left top",
      of: this.activator.$node,
      collision: "flip"
    }, property(this._config, "menu.position") );

    this._state = {
      open: false,
      position: null // Default is empty - update this dynamically by passing
                     // to component.open() - will be reset on component.close()
                     // See config._position (above) and jQueryUI documentation
                     // for what value(s) are required.
    }

    this.container.$node.addClass("ActivatedMenu"); // Also add the main component class.
    this.$node.addClass("ActivatedMenu_Menu");
    this.$node.attr("role", "menu");
    this.$node.attr("aria-labelledby", this.activator.$node.attr("id"));
    this.$node.data("instance", this); // Add reference for instance from original node.
    this.container.$node.css("width", this.$node.width() + "px"); // Required for alternative positioning.

    ActivatedMenu.bindMenuEventHandlers.call(this);
    ActivatedMenu.setMenuOpenPosition.call(this);

    this.close();

    this.$items = this.$node.find(ITEMS_SELECTOR);
    this.currentFocusIndex = 0;    
    this.initializeMenuItems();
  }


  initializeMenuItems() {
    const menu = this;
    this.$node.find('li').each( function() {
      new ActivatedMenuItem($(this), menu);
    });
  }

  isOpen() {
    return this._state.open;
  }

  // Opens the menu.
  // @position (Object) Optional (jQuery position) object.
  open(config = {}) {
    console.log(config.position);
    if(config.position) {
      // Use the passed postion values, without question.
      ActivatedMenu.setMenuOpenPosition.call(this, config.position);
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
      ActivatedMenu.calculateMenuOpenPosition.call(this, this.activator.$node);
    }
    this.container.$node.position(this._state.position);
    this.container.$node.show();
    this.activator.$node.addClass("active");
    this.activator.$node.attr("aria-expanded", true);
    this._state.open = true;
  }

  // Method
  close() {
    this.closeAllSubmenus();
    this._state.open = false;
    this.container.$node.hide();
    this.activator.$node.removeClass("active");
    this.activator.$node.removeAttr("aria-expanded");
    this.activator.$node.focus();

    // Reset any externally/temporary setting of
    // component._state.position back to default.
    ActivatedMenu.resetMenuOpenPosition.call(this);
  }


  closeAllSubmenus() {
    var $subMenus = this.$node.find('ul[role="menu"]');
    $subMenus.each(function() {
      $(this).hide();
    });
  }
  
  focus(index = 0) {
    var $items = this.$items;

    if( index > $items.length - 1 ) {
      index = 0;
    }
    if( index < 0 ) {
      index = $items.length - 1;
    }
    this.currentFocusIndex = index;
    var $item = $($items[index]).find('> :first-child');
    $item.focus();
    this.$node.attr('aria-activedescendant', $item.attr('id'));
  }

  focusNext(){
    this.focus( this.currentFocusIndex + 1 ); 
  }

  focusPrev() {
    this.focus( this.currentFocusIndex - 1 ); 
  }

  focusItem($node) {
      var index = this.$items.index($node);
      this.focus(index);
  }

  focusLast() {
      var index = this.$items.length - 1;
      this.focus(index);
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
    component._state.close = true;
    if(!$.contains(event.currentTarget, event.relatedTarget)) {
      setTimeout(function(e) {
        if(component._state.close) {
          component.close();
        }
      }, 100);
    }
  });

  this.$node.on("mouseover", (event) => {
    component._state.close = false;
  });

  this.$node.on('keydown', (event) => {
    if(this._state.open) {
      let key = event.originalEvent.key;
      let shiftKey = event.originalEvent.shiftKey;

      switch(key) {
        case 'Home':
          event.preventDefault();
          this.focus(0);
          break;
        case 'End':
          event.preventDefault();
          this.focusLast();
          break;
        case 'ArrowDown':
          event.preventDefault();
          this.focusNext();
          break;
        case 'ArrowUp':
          event.preventDefault();
          this.focusPrev();
          break;
        case 'Escape': 
          this.close();
          this.activator.$node.focus();
          break;
        case 'Tab':
          event.preventDefault();
          let tabbableElements = tabbable(document, { displayCheck: 'full' })
          let index = tabbableElements.indexOf(this.activator.$node[0]);
          //focus on the next item after the actvator node
          if( shiftKey ) {
            tabbableElements[index-1].focus();
          } else {
            tabbableElements[index+1].focus();
          }
          this.close();
          break; 
      }
    }
  });


  // Add a trigger for any listening document event
  // to activate on menu item selection.
  if(this._config.selection_event) {
    let component = this;
    component.$node.on("menuselect", function(event, ui) {
      var e = event.originalEvent;
      var original = {};

      if(e) {
        if(component._config.preventDefault) {
          e.preventDefault();
          original.element = e.target;
          original.event = e;
        }
      }


      $(document).trigger(component._config.selection_event, {
        activator: ui.item,
        menu: event.currentTarget,
        component: component,
        original: original
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
ActivatedMenu.calculateMenuOpenPosition = function($activator) {
  // var activatorLeft = $activator.offset().left;
  var activatorLeft = $activator[0].getBoundingClientRect().left;
  var rightBoundary = window.innerWidth;
  var menuWidth = this.$node.outerWidth();

  if(rightBoundary - activatorLeft < menuWidth) {
    ActivatedMenu.setMenuOpenPosition.call(this, {
      my: "right top",
      at: "right top",
      of: $activator
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
module.exports = ActivatedMenu;



