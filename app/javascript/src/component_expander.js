/**
 * Expander Component
 * ----------------------------------------------------
 * Description:
 * Creates an area that expands and contracts, activated by a single title element.
 *
 * Implements the following behaviour:
 *  - Takes a provided element, and enhances the content within it to be a
*  disclosure widget either using a provided element as a toggle, or by
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
*     var $title = $(dl).find('> dt').first();
*     new Expander($list, {
*       title: $title,
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
*   - title: (jQuery|string)   If a jQuery object it should be the first child of
*                              the $node. If the element itself is not a button, 
*                              the element will be enhanced by wrapping its contents 
*                              with a <button>.
*                              If a string is provided, a button will be created and
*                              prepended to the $node using the title text as the
*                              button label.
*   - wrap_content: (boolean)  If true will wrap all content of the
*                              $node aside from the $title with a wrapper <div>
*   - auto_open: (boolean)     If true, the comonent will be open on page load. 
*   - duration: (integer)      The duration in ms of the open/close animation.
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
      title: null,
      wrap_content: true,
      auto_open: false,
      duration: 0,
    }, config);

    if(!conf.title) {
      console.warn('Cannot initialise an Expander without a title element.');
      return;
    }

    $node.addClass("Expander");
    $node.data("instance", this);

    this.#config = conf;
    this.#state = 'open';
    this.$node = $node;

    const id = uniqueString("Expander_");

    if(typeof conf.title == 'string') {
      // We create a button using the title for a label and prepend it to the 
      // container to toggle disclosure
      let $activator = this.#createActivator(id, conf.title);
      $node.prepend($activator);
      this.$activator = $activator;
    } else if (conf.title.is('button')) {
      // we enhance the button with the required aria attributes and event
      // listener
      this.#enhanceActivator(conf.title, id);
      this.$activator = conf.title;
    } else {
      // We enhance the title element by wrapping its contents with a button
      let $title = conf.title;
      let $activator = this.#createActivator(id);
      $title.wrapInner($activator);
      $title.addClass("Expander__title");
      this.$activator = $title.find('button');
    }
 
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

  #createActivator(id, title='') {
    const $activator = $('<button>'+title+'</button>');
    this.#enhanceActivator($activator, id);

    return $activator;
  }

  #enhanceActivator($activator, id) {
    $activator.attr({
      'aria-expanded': this.#config.auto_open,
      'aria-controls': id
    });
    $activator.addClass('Expander__activator');

    $activator.on("click", () => {
      this.toggle();
    });
  }
  
}
  module.exports = Expander;
