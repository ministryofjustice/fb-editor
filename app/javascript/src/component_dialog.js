/**
 * Dialog Component
 * ----------------------------------------------------
 * Description:
 * Enhances jQueryUI Dialog component to make a simple message dialog.
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
 * config.onOk takes a function to run when 'Ok' button is activated.
 *
 * @$node  (jQuery node) Element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class Dialog {
  constructor($node, config) {
    var conf = config || {};
    var classes = conf.classes || {};
    var buttons = conf.buttons || [
      {
        text: conf.okText,
        click: () => {
          $node.dialog("close");
        }
      }];

    var id = $node.attr("id");
    var $container = $(); // Prevent jQuery errors if does not get a value

    if($node && $node.length) {
      $node.dialog({
        autoOpen: conf.autoOpen || false,
        buttons: buttons,
        classes: classes,
        closeOnEscape: true,
        height: "auto",
        modal: true,
        resizable: false
      });

      $container = $node.parents(".ui-dialog");
      $container.addClass("Dialog");

      if(!$container.attr("id")) {
        $container.attr("id", (id || utilities.uniqueString()) + "-container");
      }

      $node.data("instance", this);
      $node.on( "dialogclose", function( event, ui ) {
        $(document).trigger("DialogClose");
      });

      Dialog.setElements.call(this, $node);
      Dialog.setDefaultText.call(this, $node);
    }

    this._config = conf;
    this.$container = $container;
    this.$node = $node;
  }

  get content() {
    return this._defaultText;
  }

  set content(text) {
    this._elements.heading.text(text.heading || this._defaultText.heading);
    this._elements.content.text(text.content || this._defaultText.content);
    this._elements.ok.text(text.ok || this._defaultText.ok);
  }

  open(text) {
    var $node = this.$node;
    this.content = text || {};
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
}

/* Private
 * Finds required elements to populate this._elements property.
 **/
Dialog.setElements = function($node) {
  var elements = {};
  var $buttons = $node.parents(".Dialog").find(".ui-dialog-buttonset button");

  elements.heading = $node.find("[data-node='heading']");
  elements.content = $node.find("[data-node='content']");

  // Added by the jQueryUI widget so harder to get.
  elements.ok = $buttons.eq(0);
  
  // Don't want this button so hide it.
  $buttons.eq(1).hide();

  this._elements = elements;
}

/* Private
 * Finds on-load text to use as default values.
 **/
Dialog.setDefaultText = function($node) {
  this._defaultText = {
    heading: this._elements.heading.text(),
    content: this._elements.content.text(),
    ok: this._elements.ok.text()
  };
}


// Make available for importing.
module.exports = Dialog;

