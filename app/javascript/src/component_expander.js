/**
 * Expander Component
 * ----------------------------------------------------
 * Description:
 * Creates an area that expands and contracts, activated by a single title element.
 *
 * Implements the following behaviour:
 *  - Takes a provided element, finds the configured title element and enhances
*  it by wrapping the contents with a <button> activator.
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
*       title_tag: 'dt',
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

  constructor($node, config) {
    const conf = mergeObjects({
      title_tag: 'h2',
      wrap_content: false,
      auto_open: false,
      duration: 0,
    }, config);

    $node.addClass("Expander");
    $node.data("instance", this);

    this.#config = conf;
    this.$node = $node;

    const id = uniqueString("Expander_");

    const $activator = this.#createActivator(id);
    const $title = this.$node.find('> ' + conf.title_tag).first();
    $title.wrapInner($activator);
    $title.addClass("Expander__title");
        
    if(conf.wrap_content) {
      $title.nextAll().wrapAll('<div></div>');
    } 
       
    const $container = $title.next();
    $container.attr("id", id);
    $container.addClass("Expander__container");

    this.$title = $title;
    this.$activator = $title.find('button').first();
    this.$container = $container;
    
    conf.auto_open ? this.open() : this.close();
  }

  open() {
    this.$node.removeClass('is-closed').addClass("is-open");
    this.$container.slideDown( this.#config.duration, () => {
      this.$activator.attr("aria-expanded", "true");
      this.#config.opened = true;
    });
  }

  close() {
    this.$node.removeClass("is-open").addClass("is-closed");;
    this.$container.slideUp( this.#config.duration, () => {
      this.$activator.attr("aria-expanded", "false");
      this.#config.opened = false;
    });
  }

  isOpen() {
    return this.#config.opened == true;
  }

  toggle() {
    this.isOpen() ? this.close() : this.open();
  }

  #createActivator(id) {
    const $activator = $('<button></button>');
    $activator.attr({
      'aria-expanded': this.#config.auto_open,
      'aria-controls': id
    });
    $activator.addClass('Expander__activator');

    $activator.on("click", () => {
      this.toggle();
    });
    
    return $activator;
  }
  
}
  module.exports = Expander;
