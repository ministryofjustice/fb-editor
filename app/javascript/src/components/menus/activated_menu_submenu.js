const { uniqueString } = require('../../utilities');

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
          if(component.state.closing) {
            component.close();
          }
        }, 100);
      }
    });

    this.$node.on("mouseover", (event) => {
      component.state.closing = false;
    });

    this.$node.on('keydown', (event) => {

      if(this.state.open) {
        let key = event.originalEvent.key;
        let shiftKey = event.originalEvent.shiftKey;

        switch(key) {
          case 'Home':
            event.preventDefault();
            event.stopImmediatePropagation();
            this.focus(0);
            break;
          case 'End':
            event.preventDefault();
            event.stopImmediatePropagation();
            this.focus(this.$items.length -1);
            break;
          case 'ArrowDown':
            event.preventDefault();
            event.stopImmediatePropagation();
            this.focusNext();
            break;
          case 'ArrowUp':
            event.preventDefault();
            event.stopImmediatePropagation();
            this.focusPrev();
            break;
          case 'ArrowLeft':
            event.preventDefault();
            this.close();
            this.parent.menu.focusItem(this.parent.$node);
            break;
          case 'Escape': 
            event.preventDefault();
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
