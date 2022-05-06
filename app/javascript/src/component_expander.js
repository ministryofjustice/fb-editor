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
*       activator_source: $(dl).find('> dt').first(),
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
*   - activator_source: (jQuery|string) If a jQuery object it should be the first child of
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
  #id;

  constructor($node, config) {
    const conf = mergeObjects({
      activator_source: "activate", // Developer mistake occured if see this text.
      wrap_content: true,
      auto_open: false,
      duration: 0,
    }, config);

    $node.addClass("Expander");
    $node.data("instance", this);

    this.#config = conf;
    this.#state = 'open';
    this.#id = uniqueString("Expander_");
    this.$node = $node;
    this.$container = this.#createContainer();
    this.$activator = this.#createActivator();

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

  /* Create/define activator element to use from the source provided
   * in the config.
   *
   * Note:
   * var source (String|jQuery element) is text or element used to acquire an activator.
   *
   * If source is:
   *  - String
   *    Create a <button> and place before the content.
   *
   *  - <button>
   *    Just use/enhance that.
   *
   *  - Empty element
   *    Treat it like a button (no extra support).
   *
   *  - Non-empty element
   *    Wrap it's text content with a button, and replace the content of source
   *    element (it is assumed no other elements are inside the source but this
   *    method will prevent trying to add elements inside a button.
   *
   **/
  #createActivator() {
    var source = this.#config.activator_source;
    var $activator;

    if(typeof source == 'string') {
      $activator = $('<button>' + source + '</button>');
      this.$node.before($activator);
    }
    else {
      // Assume source to be jQuery element from this point.
      if(source.is('button')) {
        $activator = source;
      }
      else {
        if(source.children().length < 0) {
          $activator = source; // No extra support for Empty element, yet.
        }
        else {
          $activator = $('<button>' + source + '</button>');
          $activator.text(source.text()); // Only want text not child elements.
          source.empty();
          source.append($activator);
        }
      }
    }

    // Now we should have a suitable element we can do the rest.
    $activator.addClass('Expander__activator');
    $activator.attr({
      'aria-expanded': this.#config.auto_open,
      'aria-controls': this.#id
    });

    $activator.on("click", () => {
      this.toggle();
    });

    return $activator;
  }


  /* Depending on the markup we're using, and our preferred end result, we either
   * want to wrap the $node content in a $container or just leave the $node to
   * become the wrapper of the Expander.
   *
   * e.g. You wouldn't need a wrapper if your intention is this...
   *
   * <dl>
   *  <dt class="this-becomes-the-activator">Blah</dt>
   *  <dd class="this-was-the-node and this-becomes-the-container">Blah Blah</dd>
   * </dt>
   *
   * but you would want it for this outcome...
   *
   * <section class="this-was-the-node">
   *   <h2 class="this-was-activator-source"><button class="inserted-activator">Blah</h2>
   *   <div class="created-wrapper-becomes-the-container">
   *     <p>Blah</p>
   *     <p>Blah</p>
   *   </div>
   * </section>
   *
   *
   **/
  #createContainer() {
    var $container;

    if(this.#config.wrap_content) {
      $container = $("<div></div>");

      // In case config.activator_source was an element inside the $node
      // and is either going to be the $activator or wrapping it, filter it out.
      $container.append(this.$node.children().not(this.#config.activator_source));

      // Now add the container as last child to $node.
      this.$node.append($container);
    }
    else {
      $container = $node; // Change nothing
    }

    $container.attr("id", this.#id);
    $container.addClass("Expander__container");

    return $container;
  }

}


module.exports = Expander;
