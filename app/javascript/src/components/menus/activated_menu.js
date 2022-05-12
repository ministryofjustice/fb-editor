/**
 * Activated Menu Component
 * ----------------------------------------------------
 * Description:
 * Enhances a <ul> or <ol> into an accessible multi-level application menu, adding a menu
 * button to open the menu.
 *
 * This class does the following:
 *  - Takes the provided jQuery <ul> node and wraps it in an 
 *    ActvatedMenuContainer
 *  - If an activator node is not provided, creates and inserts an
 *    ActavtedMenuActivator button \
 *  - Enhances all <li> elements into ActivatedMenuItems
 *
 * Configuration:
 * The constructor also accepts a config object with the following properties:
 *  - activator (jQuery) object that will be enhanced into an
 *                       ActivatedMenuActivator.  If none is provided, an element
 *                       will be created and inserted.
 *  - activator_classname (string) class(es) to be added to the created activator
 *  - activator_text (string) accessible label for the created activator element
 *  - container_id (string) an HTML id attribute to be applied to the generated
 *                          ActivatedMenuContainer element.  If none is provided 
 *                          a unique id will be generated.
 *  - container_classname (string) class(es) to be applied to the generated menu
 *                                 container element
 *  - menu (object) 
 *  - prevent_default (bool) prevent the default event on item nodes
 *                           (<a>,<button>)
 *  - selection_event (string) if provided, in addition to the  `menuselect` event 
 *                             on the <ul> the component will trigger this event 
 *                             on the `document` allowing external components to 
 *                             listen for menu events.
 *
 *
 * Related:
 *  - ActivatedMenuContainer (activated_menu_container.js)
 *  - ActivatedMenuActivator  (activated_menu_activator.js)
 *  - ActivatedMenuItem (activated_menu_item.js)
 *
 * References:
 *  - https://www.w3.org/TR/wai-aria-practices/#menu for implemented keyboard
 * behaviours.
 *  - https://api.jqueryui.com/position/ 
 * 
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
  #className
  #config
  #position
  #state

  constructor($menu, config) {
    if(!config.container_id) {
      config.container_id = uniqueString("menu");
    }

    this.$node = $menu;
    this.#config = config;
    this.#className = "ActivatedMenu";

    this.#addAttributes();
    this.activator = new ActivatedMenuActivator(this, config);
    this.container = new ActivatedMenuContainer(this, config);  

    // Default position settings (can be set on instantiation or overide
    // on-the-fly by passing to component.open() function. Passing in a
    // position object will set the temporary value this.#state.position.
    this.#position = mergeObjects({
      my: "left top",
      at: "left top",
      of: this.activator.$node,
      collision: "flip"
    }, property(this._config, "menu.position") );

    // Default position is empty - update this dynamically by passing
    // to component.open() - will be reset on component.close()
    // See this.#position (above) and jQueryUI documentation
    // for what value(s) are required.
    this.#state = {
      open: false,
      position: null
    }

    this.#bindMenuEventHandlers();
    this.#setMenuOpenPosition();
    this.#initializeMenuItems();

    this.$node.data("instance", this); // Add reference for instance from original node.
    this.$items = this.$node.find(ITEMS_SELECTOR);
    this.currentFocusIndex = 0;    
    this.close();
  }

  get config() {
    return this.#config;
  }

  get state() {
   return this.#state;
  }

  get position() {
    return this.#position;
  }

  set currentActivator(element) {
    this.#state.activator = element;
  }

  isOpen() {
    return this.#state.open;
  }

  // Opens the menu.
  // @position (Object) Optional (jQuery position) object.
  open(config = {}) {
    if(config.position) {
      this.#setMenuOpenPosition(config.position);
    }
    else {
      this.#calculateMenuOpenPosition(this.activator.$node);
    }
    this.container.$node.position(this.state.position);
    this.container.$node.show();
    this.activator.$node.addClass("active");
    this.activator.$node.attr("aria-expanded", true);
    this.#state.open = true;
  }

  close() {
    this.closeAllSubmenus();
    this.#state.open = false;
    this.container.$node.hide();
    this.activator.$node.removeClass("active");
    this.activator.$node.removeAttr("aria-expanded");
    this.activator.$node.focus();

    // Reset any externally/temporary setting of
    // component._state.position back to default.
    this.#resetMenuOpenPosition();
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
    var $item = $($items[index]).find('> :first-child');
    if($item.parent().is('[aria-disabled]')) {
      // if item is disabled, skip it
      if( index > this.currentFocusIndex) {
        this.focus(index+1);  
      } else {
        this.focus(index-1);  
      }
    } else {
      this.currentFocusIndex = index;
      $item.focus();
      this.$node.attr('aria-activedescendant', $item.attr('id'));
    }
  }

  focusNext(){
    this.focus( this.currentFocusIndex + 1 ); 
  }

  focusPrev() {
    this.focus( this.currentFocusIndex - 1 ); 
  }

  focusItem($node) {
      const index = this.$items.index($node);
      this.focus(index);
  }

  focusLast() {
      const index = this.$items.length - 1;
      this.focus(index);
  }

  #initializeMenuItems() {
    const menu = this;
    this.$node.find('li').each( function() {
      new ActivatedMenuItem($(this), menu);
    });
  }

  #addAttributes() {
    this.$node.addClass(this.#className);
    this.$node.attr("role", "menu");
  }

  #bindMenuEventHandlers() {
    const component = this;

    this.$node.on("mouseout", (event) => {
      // event.currentTarget will be the menu (UL) element.
      // check if relatedTarget is not a child element.
      this.#state.close = true;
      if(!$.contains(event.currentTarget, event.relatedTarget)) {
        setTimeout(function(e) {
          if(component.state.close) {
            component.close();
          }
        }, 100);
      }
    });

    this.$node.on("mouseover", (event) => {
      this.#state.close = false;
    });

    this.$node.on('keydown', (event) => {
      if(this.state.open) {
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
    if(this.config.selection_event) {
      let component = this;
      component.$node.on("menuselect", function(event, ui) {
        var e = event.originalEvent;
        var original = {};

        if(e) {
          if(component.config.preventDefault) {
            e.preventDefault();
            original.element = e.target;
            original.event = e;
          }
        }

        $(document).trigger(component.config.selection_event, {
          activator: ui.item,
          menu: event.currentTarget,
          component: component,
          original: original
        });
      });
    }
  }

  /* 
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
  #setMenuOpenPosition(position) {
    var pos = position || {};
    this.#state.position = {
      my: (pos.my || this.position.my),
      at: (pos.at || this.position.at),
      of: (pos.of || this.position.of)
    }
  }

  /* 
   * Positions the menu in relation to the activator and default
   * position values, but tries to calculate if needs to reverse
   * the open position based on if the activator is too far right.
   **/
  #calculateMenuOpenPosition($activator) {
    var activatorLeft = $activator[0].getBoundingClientRect().left;
    var rightBoundary = window.innerWidth;
    var menuWidth = this.$node.outerWidth();

    if(rightBoundary - activatorLeft < menuWidth) {
      this.#setMenuOpenPosition({
        my: "right top",
        at: "right top",
        of: $activator
      });
    }
    else {
      this.#setMenuOpenPosition();
    }
  }

  /*
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
  #resetMenuOpenPosition() {
    var node = this.container.$node.get(0);
    node.style.left = "";
    node.style.right = "";
    node.style.top = "";
    node.style.bottom = "";
    node.style.position = "";
    this.#state.position = null; // Reset because this one is set on-the-fly
  }
}
module.exports = ActivatedMenu;



