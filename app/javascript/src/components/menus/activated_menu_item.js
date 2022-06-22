/**
 * Activated Menu Item
 * -----------------------------------------------------------------------------
 * Description
 * Enhances an item within an Activated Menu to be interactive and add
 * accessible behaviours. It will also instantiate an ActivatedMenuSubmenu for
 * any sub menus that are siblings of the passed $node.
 *
 * N.B. It is expected that the passed node is contained within the <li> item
 * within an ActivatedMenu <ul>.  It shoudl not be the <li> element itself.
 *
 **/

const { uniqueString } = require('../../utilities');
const ActivatedMenuSubmenu =require('./activated_menu_submenu');

class ActivatedMenuItem {

  /*
   * @param $node (jQuery) a jQuery wrapped node 
   * @param menu (ActivatedMenu) the top-level ActivatedMenu
   **/
  constructor($node, menu) {
    this.$node = $node;
    this.submenu = false;
    this.menu = menu;

    this.#setSubmenu();
    this.#addAttributes();
    this.#bindEventHandlers();
  }

  hasSubmenu() {
    return this.submenu;
  }

  activate() {
    this.menu.$node.trigger("menuselect", { item: this.$node } );
  }

  #addAttributes() {
    var item = this.$node.find(' > :first-child');
    var role = $(item).attr("role");

    if(!role) {
      $(item).attr("role", "menuitem");
    }
    $(item).attr("tabindex", "-1");
    $(item).attr("id", uniqueString("menuItem"));

    if(this.hasSubmenu()) {
      $(item).attr("aria-haspopup", "menu");
      $(item).attr("aria-expanded", "false");
    }
  }

  #setSubmenu() {
    const $submenu = this.$node.find('ul').first();
    if( $submenu.length > 0 ) {
      this.submenu = new ActivatedMenuSubmenu($submenu, this);
    }
  }

  #bindEventHandlers() {  
    var item = this;

    this.$node.on("click", (event) => {
      event.preventDefault();
      this.activate( );
    });

    this.$node.on("mouseenter", (event) => {
      if(this.hasSubmenu()) {
        setTimeout(function(e) {
          item.submenu.open(); 
        }, 50);
      } 
    });

    this.$node.on("mouseout", (event) => {
      if( this.hasSubmenu() ) {
        if( this.submenu.isOpen() ) {
          if(!$.contains(event.currentTarget, event.relatedTarget)) {
            setTimeout(function(e) {
              item.submenu.close(); 
            }, 50);
          }
        }
      }
    });

    this.$node.on("keydown", (event) => {
      if(this.menu.isOpen()) {
        let key = event.originalEvent.code;
        let shiftKey = event.originalEvent.shiftKey;

        switch(key) {
          case 'ArrowRight':
            event.preventDefault();
            event.stopImmediatePropagation();
            if( this.hasSubmenu ) {
              this.submenu.open(); 
              this.submenu.focus();
            } 
            break;
          case 'Enter':
          case 'Space': 
            event.preventDefault();
            if( this.hasSubmenu() ) {
              this.submenu.open();
              this.submenu.focus();
            } else {
              this.menu.activator.$node.focus();
              this.activate();
              this.menu.close();
            }
            break;
        }
      }
    });
  }
}
module.exports = ActivatedMenuItem;
