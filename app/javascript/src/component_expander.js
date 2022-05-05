/**
 * Expander Component
 * ----------------------------------------------------
 * Description:
 * Creates an area that expands and contracts, triggered by an activator element.
 *
 * Implements the following behaviour:
 *  - Takes a provided element, and enhances the content within it to be a
*  disclosure widget either by enhancing the provided element, or by
*  creating a button.
*   - If config.wrap_content is true, it will wrap all other child elements
*   within the provided element in a <div>
*   - By default, it will collapse and hide the content.
*
*   Example:
*   Given the following:
*   <dl>
*     <dt>Title</dt>
*     <dd>Loem ipsum dolor sit amet consecteteur adipiscing elit...</dd>
*   </dl>
*   <script>
*     var $list = $(dl);
*     new Expander($list, {
*       activator: $(dl).find('> dt').first(),
*       wrap_content: false,
*     })
*   </script>
*
*   Would result the following markup:
*   <dl class="Expander close">
*     <dt class="Expander__title">
*       <button aria-expanded="false" aria-controls="Expander_12345678790">Title</button>
*     </dt>
*     <dd id="Expander_1234567890" class="Expander__container" style="display: none;">
*       Lorem ipsum.....
*     </dd>
*   </dt>
*
*   Configuration:
*   The config object can have the follwoing properties:
*   - activator: (jQuery|string) If a jQuery object it should be the first child of
*                                the $node. If the element itself is not a button, 
*                                the element will be enhanced by wrapping its contents 
*                                with a <button>.
*                                If a string is provided, a button will be created and
*                                prepended to the $node using the title text as the
*                                button label.
*   - wrap_content: (boolean)    If true will wrap all content of the
*                                $node aside from the $activator with a wrapper <div>
*   - auto_open: (boolean)       If true, the component will be open on page load. 
*   - duration: (integer)        The duration in ms of the open/close animation.
*
 **/

const { 
  mergeObjects,
  uniqueString
} = require('./utilities');

/**
 * @param $node (jQuery) Html Element to be enhanced.
 * @param condif (Object) Key/value pairs for config (see above)
**/
class Expander {
  #config;
  #state;

  constructor($node, config) {
    const conf = mergeObjects({
      activator: null,
      wrap_content: true,
      auto_open: false,
      duration: 0,
    }, config);

    if(!conf.activator) {
      console.warn('Cannot initialise an Expander without an activator element.');
      return;
    }

    $node.addClass("Expander");
    $node.data("instance", this);

    this.#config = conf;
    this.#state = 'open';
    this.$node = $node;

    const id = uniqueString("Expander_");
    var $button;

    if(typeof conf.activator == 'string') {
      // We create a button using the title for a label and prepend it to the 
      // container to toggle disclosure
      $button = this.#createButton(id, conf.activator);
      $node.prepend($button);
    } else if (conf.activator.is('button')) {
      // we enhance the button with the required aria attributes and event
      // listener 
      $button = this.#enhanceButton(conf.activator, id);
    } else {
      // We enhance the title element by wrapping its contents with a button
      let $activator = conf.activator;
      $activator.wrapInner( this.#createButton(id) );
      $activator.addClass("Expander__title");
      $button = $activator.find('button');
    }

    this.$activator = $button;
 
    if(conf.wrap_content) {
      this.$node.children().first().nextAll().wrapAll('<div></div>');
    } 

    this.$container = this.$node.children().first().next();
    this.$container.attr("id", id);
    this.$container.addClass("Expander__container");
    
    conf.auto_open ? this.open() : this.close();
  }

  open() {
    this.$container.slideDown( this.#config.duration, () => {
      this.$activator.attr("aria-expanded", "true");
      this.#state = 'open';
    });
  }

  close() {
    this.$container.slideUp( this.#config.duration, () => {
      this.$activator.attr("aria-expanded", "false");
      this.#state = 'closed';
    });
  }

  isOpen() {
    return this.#state == 'open';
  }

  toggle() {
    this.isOpen() ? this.close() : this.open();
  }

  #createButton(id, title='') {
    const $button = $('<button>'+title+'</button>');
    return this.#enhanceButton($button, id);
  }

  #enhanceButton($button, id) {
    $button.attr({
      'aria-expanded': this.#config.auto_open,
      'aria-controls': id
    });
    $button.addClass('Expander__activator');

    $button.on("click", () => {
      this.toggle();
    });

    return $button;
  }
  
}
  module.exports = Expander;
