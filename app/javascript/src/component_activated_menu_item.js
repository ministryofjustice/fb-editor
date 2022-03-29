
const utilities = require('./utilities');
const uniqueString = utilities.uniqueString;
const ActivatedMenuSubmenu = require('./component_activated_menu_submenu');

class ActivatedMenuItem {
  constructor($node, menu) {
    this.$node = $node;
    this.submenu = false;
    this.menu = menu;
    this.state = {};

    this.setSubmenu();
    this.initializeAria();
    this.bindEventHandlers();
  }

  initializeAria() {
    var item = this.$node.find(' > :first-child');
    var role = $(item).attr("role");

    if(!role) {
      $(item).attr("role", "menuitem");
      $(item).attr("tabindex", "-1");
      $(item).attr("id", uniqueString("menuItem"));
    }

    if(this.hasSubmenu()) {
      $(item).attr("aria-haspopup", "menu");
      $(item).attr("aria-expanded", "false");
    }
  }

  setSubmenu() {
    const $submenu = this.$node.find('ul').first();
    if( $submenu.length > 0 ) {
      this.submenu = new ActivatedMenuSubmenu($submenu, this);
    }
  }

  hasSubmenu() {
    return this.submenu;
  }

  activate() {
    this.menu.$node.trigger("menuselect", { item: this.$node } );
  }


  bindEventHandlers() {  
    var item = this;

    this.$node.on("click", (event) => {
      event.preventDefault();
      this.activate( );
    });

    this.$node.on("mouseenter", (event) => {
      if(this.hasSubmenu()) {
        setTimeout(function(e) {
          console.log('item mouseover - open submenu', item);
          item.submenu.open(); 
        }, 50);
      } 
    });

    this.$node.on("mouseout", (event) => {
      if( this.hasSubmenu() ) {
        if( this.submenu.isOpen() ) {
          if(!$.contains(event.currentTarget, event.relatedTarget)) {
            setTimeout(function(e) {
              console.log('item mouseout - close submenu', item);
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
