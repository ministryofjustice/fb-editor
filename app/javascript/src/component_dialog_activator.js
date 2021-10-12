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


/* @node (jQuery element) Existing element to use as an Activator (one will be generated if null).
 * @config (Object) Configurable key/value pairs, e.g.
 *                  {
 *                    dialog: // Dialog component to be controlled by the activator (Required)
 *                    classes: // CSS class names to apply to the activator (if generating one)
 *                    activatorText: // Used if an Activator needs to be generated,
 *                    $target: // Where to put a generated Activator $target.before($activator)
 *                  }
 **/
class DialogActivator {
  constructor($node, config) {
    if(!$node || $node.length < 1) {
      $node = createActivator(config.$target, config.activatorText, config.classes);
    }

    $node.on( "click", () => {
      config.dialog.open();
    });

    this.dialog = config.dialog;
    this.$node = $node;
  }
}

/* Creates a button and links with the passed dialog element.
 * @$dialog (jQuery object) Target dialog element enhanced with dialog funcitonality.
 * @text    (String) Text that will show on the button.
 * @classes (String) Classes added to button.
 **/
function createActivator($target, text, classes) {
  var $activator = $("<button>\</button>");
  $activator.text((text || "open dialog")); 
  $activator.addClass(classes);
  $target.before($activator);
  return $activator;
}


// Make available for importing.
module.exports = DialogActivator;

