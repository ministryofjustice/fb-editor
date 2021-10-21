/**
 * Dialog API Request Component
 * ----------------------------------------------------
 * Description:
 * Expects response content from an API request, which it can wrap in a Dialog effect.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

const utilities = require('./utilities');


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 *
 * @url    (URL) API request that gets the HTML used to populate the dialog.
 * @config (Object) Configurable key/value pairs.
 *
 * {
 *   activator: HTML node that activated the initial request and resulting dialog
 *   build: A function that will run just before the dialog is created.
 *          This function is passed the API response HTML wrapped in a jQuery object.
 *   buttons: Two element Array containing objects used for passing to the jQueryUI dialog.
 *            The two elements are of the construction:
 *            {
 *               text: "This is used for button text",
 *               click: function(dialog) {
 *                 // an action to run on click that receives the DialogApiRequest instance as an argument.
 *               }
 *            }
 *   closeOnClickSelector: jQuery selector to find elements that will close the dialog on their click event.
 * }
 **/
class DialogApiRequest {
  constructor(url, config) {
    var dialog = this;
    var conf = utilities.mergeObjects({
      buttons: []
    }, config);

    var jxhr = $.get(url, function(response) {
      dialog.$node = $(response);

      // Allow a passed function to run against the created $node (response HTML) before creating a dialog effect
      utilities.safelyActivateFunction(dialog._config.build, dialog);

      dialog.$node.addClass("DialogApiRequest");
      dialog.$node.data("instance", this);
      dialog.$node.dialog({
        classes: conf.classes,
        closeOnEscape: true,
        height: "auto",
        modal: true,
        resizable: false
      });
    });

    jxhr.done(function() {
      if(conf.closeOnClickSelector) {
        let $buttons = $(conf.closeOnClickSelector, dialog.$node);
        $buttons.eq(0).focus();
        $buttons.on("click", function() {
          dialog.close();
        });
      }
      else {
        dialog.$node.dialog("option", "buttons",
          [
            {
              text: dialog._config.buttons.length > 0 && dialog._config.buttons[0].text || "ok",
              click: () => {
                // Attempt to run any passed button.click action.
                if(dialog._config.buttons.length > 0) {
                  utilities.safelyActivateFunction(dialog._config.buttons[0].click, dialog);
                }

                // Make sure the dialog closes
                dialog.close();
              }
            },
            {
              text: dialog._config.buttons.length > 0 && dialog._config.buttons[1].text || "cancel",
              click: () => {
                // Attempt to run any passed button.click action.
                if(dialog._config.buttons.length > 1) {
                  utilities.safelyActivateFunction(dialog._config.buttons[1].click, dialog);
                }

                // Make sure the dialog closes
                dialog.close();
              }
            }
          ]
        );
      }
    });

    this.$node = $(); // Should be overwritten on successful GET
    this._config = conf;
  }

  open() {
    var $node = this.$node;
    this.$node.dialog("open");
    window.setTimeout(function() {
      // Not great but works.
      // We want the focus put inside dialog as all functionality to trap tabbing is there already.
      // Because we sometimes open dialogs from other components, those other components may (like
      // menus) shift focus from the opening dialog. We need this delay to allow those other events
      // to play out before we try to set focus in the dialog. Delay time is arbitrary but we
      // obviously want it as low as possible to avoid user annoyance. Increase only if have to.
      $node.parent().find("input, button").not(".ui-dialog-titlebar-close").eq(0).focus();
    }, 100);
  }

  close() {
    // Attempt to refocus on original activator
    if(this._config.activator) {
      this._config.activator.focus();
    }

    this.$node.dialog("close");
  }
}


module.exports = DialogApiRequest;
