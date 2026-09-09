/**
 * Activated Menu Submenu
 * -----------------------------------------------------------------------------
 * Description:
 * Enhances submenus within an ActivatedMenu and handles keyboard events
 *
 **/

const { uniqueString } = require('../../utilities');

const ITEMS_SELECTOR = '> li';

class ActivatedMenuSubmenu {
    #state

    /**
     * @param $node (jQuery) jQuery-wrapped <ul> node for the submenu
     * @param parent (HTMLElement) the parent <li> element
     **/
    constructor($node, parent) {
        this.$node = $node;
        this.parent = parent;

        this.#state = {
            open: false,
            closing: false,
        }

        this.$node.attr("role", "menu");
        this.$node.attr("tabindex", -1);
        this.$node.hide();

        this.$items = this.$node.find(ITEMS_SELECTOR);
        this.currentFocusIndex = 0;

        this.#bindEventHandlers();
    }

    get state() {
        return this.#state;
    }

    isOpen() {
        return this.#state.open;
    }

    open() {
        this.#state.open = true;
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
        this.#state.open = false;
        this.$node.hide();
        this.parent.$node.find('> :first-child').attr("aria-expanded", "false");
        // this.parent.menu._state.submenuOpen = false;
    }

    focus(index = 0) {
        let $items = this.$items;

        if (index > $items.length - 1) {
            index = 0;
        }
        if (index < 0) {
            index = $items.length - 1;
        }
        this.currentFocusIndex = index;
        var $item = $($items[index]).find('> :first-child');
        $item.focus();
        this.$node.attr('aria-activedescendant', $item.attr('id'));
    }

    focusNext() {
        this.focus(this.currentFocusIndex + 1);
    }

    focusPrev() {
        this.focus(this.currentFocusIndex - 1);
    }

    #bindEventHandlers() {
        var component = this;

        this.$node.on("mouseout", (event) => {
            // event.currentTarget will be the menu (UL) element.
            // check if relatedTarget is not a child element.
            this.#state.closing = true;
            this.mouseOver = false;
            if (!$.contains(event.currentTarget, event.relatedTarget)) {
                setTimeout(function(e) {
                    if (component.state.closing) {
                        component.close();
                    }
                }, 100);
            }
        });

        this.$node.on("mouseover", (event) => {
            this.mouseOver = true;
            this.#state.closing = false;
        });

        // we use StopImmediatePropagation in here to prevent the event bubbling up
        // to parent menus.  So that e.g. <esc> only closes the submenu, and not the
        // whole menu.
        this.$node.on('keydown', (event) => {
            if (this.#state.open) {
                let key = event.originalEvent.key;
                let shiftKey = event.originalEvent.shiftKey;

                switch (key) {
                    case 'Home':
                        event.preventDefault();
                        event.stopImmediatePropagation();
                        this.focus(0);
                        break;
                    case 'End':
                        event.preventDefault();
                        event.stopImmediatePropagation();
                        this.focus(this.$items.length - 1);
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
                        /* Technically <esc> should close only the submenu
                         * we are opting to have it close the whole menu. 
                         * Leaving this here in case user testing shows that just closing 
                         */
                        // event.preventDefault();
                        // event.stopImmediatePropagation();
                        // this.close();
                        // this.parent.menu.focusItem(this.parent.$node);
                        break;
                }
            }
        });
    }

}
module.exports = ActivatedMenuSubmenu;
