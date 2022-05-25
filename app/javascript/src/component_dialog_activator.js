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
 * @config (Object) Configurable key/value pairs, e.g.
 *                  {
 *                    dialog: // Dialog component to be controlled by the activator (Required)
 *                    classes: // CSS class names to apply to the activator (if generating one)
 *                    text: // Used if an Activator needs to be generated,
 *                    $target: // Where to put a generated Activator $target.before($activator)
 *                  }
 **/
class DialogActivator {
  constructor($node, config) {
    var conf = utilities.mergeObjects({
      text: "",
      classes: ""
    }, config);

    if(!$node || $node.length < 1) {
      $node = createActivator(conf.$target, conf.text);
    }

    $node.data("instance", this);
    $node.addClass("DialogActivator");
    $node.addClass(config.classes);
    $node.on( "click", () => {
      conf.dialog.open();
    });

    // Attempt to add an ID if none exists.
    if(!$node.attr("id")) {
      $node.attr("id",  utilities.uniqueString(conf.dialog.$node.attr("id")));
    }

    this.dialog = conf.dialog;
    this.$node = $node;
  }
}

/* Creates a button and links with the passed dialog element.
 * @$dialog (jQuery object) Target dialog element enhanced with dialog funcitonality.
 * @text    (String) Text that will show on the button.
 * @classes (String) Classes added to button.
 **/
function createActivator($target, text) {
  var $activator = $("<button>\</button>");
  $activator.text((text || "open dialog"));
  $target.before($activator);
  return $activator;
}


// Make available for importing.
module.exports = DialogActivator;

