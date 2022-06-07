const utilities = require('./utilities');

class DialogValidation {
  #config;
  #state;

  constructor(url, config) {
    var dialog = this;
    var conf = utilities.mergeObjects({
      closeOnClickSelector: 'button[type="button"]',
      submitOnClickSelector: 'button[type="submit"]',
      onLoad: function(dialog) {},
      onRefresh: function(dialog) {},
      beforeSubmit: function(dialog) {},
      onSuccess: function(data, dialog) {},
      onError: function(data, dialog) {},
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
      })

      // Now jQueryUI dialog is in place let's initialise container and put class on it.
      dialog.$container = dialog.$node.parents(".ui-dialog");
      dialog.$container.addClass("DialogValidation");
    });


    jxhr.done(() => {
      // Allow a function to be specified in dialog config 
      utilities.safelyActivateFunction(dialog.#config.onLoad, dialog);
      dialog.#enhance();
      dialog.open();
    });
  }

  get state() {
    return this.#state;
  }

  open() {
    this.$node.dialog("open");
    window.setTimeout(() => {
      // Not great but works.
      // We want the focus put inside dialog as all functionality to trap tabbing is there already.
      // Because we sometimes open dialogs from other components, those other components may (like
      // menus) shift focus from the opening dialog. We need this delay to allow those other events
      // to play out before we try to set focus in the dialog. Delay time is arbitrary but we
      // obviously want it as low as possible to avoid user annoyance. Increase only if have to.
      this.focus(); 
    }, 100);
  }

  close() {
    // Attempt to refocus on original activator
    if(this.#config.activator) {
      this.#config.activator.focus();
    }
    this.$node.dialog("close");
    this.$node.dialog('destroy'); 
    this.$node.remove();
  }

  submit() {
    var dialog = this;
    var $form = dialog.$node.find('form');
    $.ajax({ 
      type: 'POST',
      url: $form.attr('action'),
      data: $form.serialize(),
      success: function(data) {
        utilities.safelyActivateFunction(dialog.#config.onSuccess, data, dialog);
        dialog.close();
      },
      error: function(data) {
        utilities.safelyActivateFunction(dialog.#config.onError, data, dialog);
        dialog.focus();
      }
    });
  }

  focus() {
    var el = this.$node.parent().find('input[aria-invalid]').get(0);
    if(!el) {
      el = this.$node.parent().find('input:not([type="hidden"], [type="disabled"]), button:not([type="disabled"])').not(".ui-dialog-titlebar-close").eq(0);
    }
    if(el){
      el.focus();
    }
  }

  /* 
  * simply a function alias for better readability / nicer api 
  * expected to eb called if the dialog html is changed dynamically\
  * will re-enhance the html to add the required functionality 
  * */
  refresh() {
    this.#enhance();
  }

  #enhance() {
    var dialog = this;
    this.#setupCloseButtons();
    this.#setupSubmitButton();
    utilities.safelyActivateFunction(dialog.#config.onRefresh, dialog);
  }

  /* add event listeners to configured close buttons */
  #setupCloseButtons() {
    var dialog = this;
    if(this.#config.closeOnClickSelector) {
      let $buttons = $(this.#config.closeOnClickSelector, this.$container);
      $buttons.on("click", function() {
        dialog.close();
      });
    } 
  }

  /* add event listeners to configured submit button */
  #setupSubmitButton() {
    var dialog = this;
    if(this.#config.submitOnClickSelector) {
      let $buttons = $(this.#config.submitOnClickSelector, this.$container);
      $buttons.on("click", function(e) {
        e.preventDefault();
        utilities.safelyActivateFunction(dialog.#config.beforeSubmit, dialog );
        dialog.submit();
      });
    }
  }

}


module.exports = DialogValidation;
