const utilities = require('./utilities');
const DialogApiRequest = require('./component_dialog_api_request');


class DialogValidation {
  #config;
  #state;

  constructor(url, config) {
    var dialog = this;
    var conf = utilities.mergeObjects({
      closeOnClickSelector: 'button[type="button"]',
      submitOnClickSelector: 'button[type="submit"]',
    }, config);

    this.$node = $(); // Should be overwritten on successful GET
    this.$container = $(); // Should be overwritten on successful GET
    this.#config = conf;
    this.#state = "closed";

    var jxhr = $.get(url, function(response) {
      dialog.$node = $(response);

      // Allow a passed function to run against the created $node (response HTML) before creating a dialog effect
      utilities.safelyActivateFunction(dialog.#config.build, dialog);

      dialog.$node.data("instance", dialog);
      dialog.$node.dialog({
        classes: conf.classes,
        closeOnEscape: true,
        height: "auto",
        modal: true,
        resizable: false,
        open: function() { dialog.#state = "open"; },
        close: function() { dialog.#state = "closed"; }
      });

      // Now jQueryUI dialog is in place let's initialise container and put class on it.
      dialog.$container = dialog.$node.parents(".ui-dialog");
      dialog.$container.addClass("DialogApiRequest");
    });


    jxhr.done(() => {
      // Allow a function to be specified in dialog config 
      utilities.safelyActivateFunction(dialog.#config.done, dialog);
      this.enhance(); 
    });
  }

  get state() {
    return this.#state;
  }

  enhance() {
    var dialog = this;
    this.#setupCloseButtons();
    this.#setupSubmitButton();
    
    let $revealingCheckboxes = $('input[type="checkbox"][aria-controls]');
    $revealingCheckboxes.each(function() {
      var id = $(this).attr('aria-controls');
      var checked = $(this).prop('checked');
      var $content = dialog.$node.find('#'+id);

      if(checked) {
        $content.removeClass('govuk-checkboxes__conditional--hidden');
        $(this).attr('aria-expanded', true);
      } else {
        $content.addClass('govuk-checkboxes__conditional--hidden');
        $(this).attr('aria-expanded', false);
      }

      $(this).on('change', function() {
        var checked = $(this).prop('checked');
        if(checked) {
          $content.removeClass('govuk-checkboxes__conditional--hidden');
          $(this).attr('aria-expanded', true);
        } else {
          $content.addClass('govuk-checkboxes__conditional--hidden');
          $(this).attr('aria-expanded', false);
        }
      })
    })
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
    if(this.#config.activator) {
      this.#config.activator.focus();
    }
    this.$node.dialog("close");
  }

  #setupCloseButtons() {
    var dialog = this;
    if(this.#config.closeOnClickSelector) {
      let $buttons = $(this.#config.closeOnClickSelector, this.$node);
      $buttons.eq(0).focus();
      $buttons.on("click", function() {
        dialog.close();
      });
    } 
  }

  #setupSubmitButton() {
    var dialog = this;
    if(this.#config.submitOnClickSelector) {
      let $buttons = $(this.#config.submitOnClickSelector, this.$node);
      $buttons.on("click", function(e) {
        e.preventDefault();
        utilities.safelyActivateFunction(dialog.#config.submit, dialog );
      });
    }
  }

}


module.exports = DialogValidation;
