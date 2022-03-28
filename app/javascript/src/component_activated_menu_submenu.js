const utilities = require('./utilities');
const uniqueString = utilities.uniqueString;
const ITEMS_SELECTOR = '> li';

class ActivatedMenuSubmenu {
    constructor($node, parent) {
      this.$node = $node;
      this.parent = parent;

      this.state = {
        open: false,
        closing: false,
      }

      this.$node.attr("role", "menu");
      this.$node.attr("tabindex", -1);

      this.$items = this.$node.find(ITEMS_SELECTOR);

      this.currentFocusIndex = 0;   

      this.bindEventHandlers();
    }
  
    isOpen() {
      return this.state.open;
    }


    open() {
      console.log('open submenu', this.$node);
      this.state.open = true;
      this.$node.show();
      this.parent.$node.find('> :first-child').attr("aria-expanded", "true");
      this.$node.position({
        my: "left top",
        at: "right top-2",
        of: this.parent.$node,
        collision: "flip"
      });
    }

    close() {
      console.log('close submenu', this.$node);
      this.state.open = false;
      this.$node.hide();
      this.parent.$node.find('> :first-child').attr("aria-expanded", "false");
      this.parent.menu._state.submenuOpen = false;
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

  bindEventHandlers() {
    var component = this;

    this.$node.on("mouseout", (event) => {
      // event.currentTarget will be the menu (UL) element.
      // check if relatedTarget is not a child element.
      component.state.closing = true;
      if(!$.contains(event.currentTarget, event.relatedTarget)) {
        setTimeout(function(e) {
          console.log('submenu mouseout  - close', component);
          if(component.state.closing) {
            component.close();
          }
        }, 100);
      }
    });


    this.$node.on('keydown', (event) => {

      if(this.state.open) {
        event.preventDefault();
        let key = event.originalEvent.key;
        let shiftKey = event.originalEvent.shiftKey;

        switch(key) {
          case 'Home':
            event.stopImmediatePropagation();
            this.focus(0);
            break;
          case 'End':
            event.stopImmediatePropagation();
            this.focus(this.$items.length -1);
            break;
          case 'ArrowDown':
            event.stopImmediatePropagation();
            console.log('submenu down');
            this.focusNext();
            break;
          case 'ArrowUp':
            event.stopImmediatePropagation();
            this.focusPrev();
            break;
          case 'ArrowLeft':
            this.close();
            this.parent.menu.focusItem(this.parent.$node);
            break;
          case 'Escape': 
            event.stopImmediatePropagation();
            this.close();
            this.parent.menu.focusItem(this.parent.$node);
            break;
        }
      }
    });
  }
    
}
module.exports = ActivatedMenuSubmenu;
