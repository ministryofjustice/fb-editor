/**
 * Dialog Activator Component
 * ----------------------------------------------------
 * Description:
 * Creates a button to open an associated dialog component.
 *
 * Documentation:
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');


/* @node (jQuery element) Existing element to use as an Activator (one will be generated if null).
 * @config (Object) Configurable key/value pairs
 *          - dialog:  (Dialog)      Dialog component to be controlled by the activator (Required)
 *          - classes: (String)      CSS class names to apply to the activator (if generating one)
 *          - text:    (String)      Used if an Activator needs to be generated,
 *          - $target: (jQuery node) Where to put a generated Activator $target.before($activator)
 **/
class DialogActivator {
  #config;

  constructor($node, config) {
    this.#config = utilities.mergeObjects({
      text: "",
      classes: ""
    }, config);

    if(!$node || $node.length < 1) {
      $node = this.#createActivator();
    }

    $node.data("instance", this);
    $node.addClass("DialogActivator");
    $node.addClass(this.#config.classes);
    $node.on( "click", () => {
      conf.dialog.open();
    });

    this.dialog = this.#config.dialog;
    this.$node = $node;
  }

  /* Creates a button and links with the passed dialog element.
   * @$dialog (jQuery object) Target dialog element enhanced with dialog funcitonality.
   * @text    (String) Text that will show on the button.
   * @classes (String) Classes added to button.
   **/
  #createActivator() {
    var $target = this.#config.$target;
    var $activator = $("<button>\</button>");

    $activator.text((this.#config.text || "open dialog"));

    if($target && $target.length) {
      // Add it to DOM using the specified $target.
      $target.before($activator);
    }
    else {
      // Try to add it before the dialog.$node
      this.#config.dialog.$container.before($activator);
    }

    return $activator;
  }

}


// Make available for importing.
module.exports = DialogActivator;

