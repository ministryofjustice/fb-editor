const {
mergeObjects,
safelyActivateFunction, 
} = require('./utilities');

class DialogValidation {
  #config;

  constructor(source, config) {
    this.#config = mergeObjects({
      autoOpen: false,
      closeOnClickSelector: 'button[type="button"]',
      submitOnClickSelector: 'button[type="submit"]',
      remote: false,
      onLoad: function(dialog) {},
      onReady: function(dialog) {},
      beforeSubmit: function(dialog) {},
      onSuccess: function(data, dialog) {},
      onError: function(data, dialog) {},
      onOpen: function(dialog) {},
      onClose: function(dialog) {},
    }, config);
    
    this.$node = $(); // Should be overwritten once intialised
    this.$container = $(); // Should be overwritten once intialised
    this.$form = $(); // Should be overwritten on successful GET

    this.#initialize(source); 
  }

  isOpen() {
    return this.$node.dialog("isOpen");
  }

  open() {
    var dialog = this;
    this.$node.dialog("open");
    safelyActivateFunction(this.#config.onOpen, dialog);
    window.setTimeout(() => {
      // Not great but works.
      // We want the focus put inside dialog as all functionality to trap tabbing is there already.
      // Because we sometimes open dialogs from other components, those other components may (like
      // menus) shift focus from the opening dialog. We need this delay to allow those other events
      // to play out before we try to set focus in the dialog. Delay time is arbitrary but we
      // obviously want it as low as possible to avoid user annoyance. Increase only if have to.
      dialog.focus(); 
    }, 100);
  }

  close() {
    var dialog = this;
    // Attempt to refocus on original activator
    if(this.#config.activator) {
      this.#config.activator.focus();
    }
    if(this.$node.dialog("instance")) {
      this.$node.dialog("close");
      this.$node.dialog('destroy'); 
    }
    this.$node.remove();
    utilities.safelyActivateFunction(dialog.#config.onClose, dialog);
  }

  submit() {
    if( this.#config.remote ) {
      this.submitRemote();
    } else {
      this.$form.submit();
    }
  }

  submitRemote() {
    var dialog = this;
    $.ajax({ 
      type: 'POST',
      url: dialog.$form.attr('action'),
      data: dialog.$form.serialize(),
      success: function(data) {
        safelyActivateFunction(dialog.#config.onSuccess, data, dialog);
        dialog.close();
      },
      error: function(data) {
        safelyActivateFunction(dialog.#config.onError, data, dialog);
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
  * expected to be called if the dialog html is changed dynamically 
  * will re-enhance the html to add the required functionality 
  * */
  refresh() {
    this.#enhance();
  }

  #initialize(source) {
    var dialog = this;

    if(typeof source == 'string') {
      $.get(source, (response) =>  {
        this.$node = $(response);
        this.#build(); 
      })
      .done(() => {
        // Allow a function to be specified in dialog config 
        safelyActivateFunction(dialog.#config.onLoad, dialog);
        this.#enhance();
        if(this.#config.autoOpen) {
          this.open();
        }
      })
    } else { 
      this.$node = source;
      this.#build();
      this.#enhance();
      if(this.#config.autoOpen) {
        this.open();
      }
    }
  }

  #build() {
    var dialog = this;

    this.$node.on("dialogcreate", (event, ui) => {
      this.$container = dialog.$node.parents(".ui-dialog");
      this.$container.addClass("DialogForm");
    });

    // Add the jQueryUI dialog functionality.
    this.$node.dialog({
      autoOpen: false,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
    });
    
    this.$node.data("instance", this);
  }

  #enhance() {
    var dialog = this;
    this.$form = this.$node.find('form');
    this.#setupCloseButtons();
    this.#setupSubmitButton();
    safelyActivateFunction(dialog.#config.onReady, dialog);
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
        safelyActivateFunction(dialog.#config.beforeSubmit, dialog );
        dialog.submit();
      });
    }
  }

}


module.exports = DialogValidation;
