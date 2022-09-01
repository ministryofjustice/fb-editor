const {
mergeObjects,
safelyActivateFunction, 
} = require('./utilities');

const DialogActivator = require('./component_dialog_activator');

class DialogForm {
  #className = 'DialogForm';
  #config;
  #remoteSource;
  #state;

  constructor(source, config) {
    this.#config = mergeObjects({
      activator: false,
      autoOpen: false,
      classes: {},
      closeOnClickSelector: 'button[type="button"]',
      submitOnClickSelector: 'button[type="submit"]',
      remote: false,
      disableOnSubmit: '',
      onLoad: function(dialog) {},
      onReady: function(dialog) {},
      beforeSubmit: function(dialog) {},
      onSuccess: function(data, dialog) {},
      onError: function(data, dialog) {},
      onOpen: function(dialog) {},
      onClose: function(dialog) {},
    }, config);
   
    this.#remoteSource = false;
    this.#state = "closed";
    this.$node = $(); // Should be overwritten once intialised
    this.$container = $(); // Should be overwritten once intialised
    this.$form = $(); // Should be overwritten on successful GET

    this.#initialize(source);
  }

  get activator() {
    return this.#config.activator;
  }

  set activator($node) {
    this.#config.activator = $node;
  }

  get state() {
    return this.#state;
  }

  isOpen() {
    return this.state == "open";
  }

  open() {
    var dialog = this;

    if(this.$node.dialog('instance')) {
      this.$node.dialog("open");
      this.#state = "open";
      safelyActivateFunction(this.#config.onOpen, dialog);

      queueMicrotask(() => {
        dialog.focus();
      });
    }
  }

  close() {
    var dialog = this;
    // Attempt to refocus on original activator
    this.focusActivator();

    if(this.$node.dialog('instance')) {
      this.$node.dialog("close");
      safelyActivateFunction(dialog.#config.onClose, dialog);
      this.#state = "closed";
    }

    if(this.#remoteSource){
      this.#destroy();
    }
  }

  submit() {
    if( this.#config.remote ) {
      this.#submitRemote();
    } else {
      this.$form.submit();
    }
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

  focusActivator() {
    // Attempt to refocus on original activator
    if(this.activator) {
      this.activator.focus();
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
      this.#remoteSource = true;
      $.get(source)
      .done((response) => {
        this.$node = $(response);
        this.#build(); 
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
    
    if(this.activator) {
      this.#createActivator();
    }

    this.$node.dialog({
      autoOpen: false,
      classes: this.#config.classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
    });
    
    this.$container = dialog.$node.parents(".ui-dialog");
    this.$container.addClass(dialog.#className);
    this.$node.data("instance", dialog);
  }

  #enhance() {
    var dialog = this;

    this.$form = this.$node.is('form') ? this.$node : this.$node.find('form');

    if(this.#config.closeOnClickSelector) {
      this.#setupCloseButtons();
    }

    if(this.#config.submitOnClickSelector) {
      this.#setupSubmitButton();
    }

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
    let $button = $(this.#config.submitOnClickSelector, this.$container).first();
    $button.on("click", function(e) {
      e.preventDefault(); 
      if(dialog.#config.remote && dialog.#config.disableOnSubmit) {
        $button.text(dialog.#config.disableOnSubmit);
        $button.attr('disabled', 'disabled');
      }
      safelyActivateFunction(dialog.#config.beforeSubmit, dialog );
      dialog.submit();
    });
  }

  #submitRemote() {
    var dialog = this;

    $.ajax({ 
      type: 'POST',
      url: dialog.$form.attr('action'),
      data: new FormData(dialog.$form.get(0)),
      processData: false,
      contentType: false,
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

  #destroy() {
    if(this.$node.dialog('instance')) {
      this.$node.dialog('destroy'); 
    }
    this.$node.remove();
  }

  #createActivator() {
    var $marker = $("<span></span>");

    this.$node.before($marker);
    var activator = new DialogActivator(this.#config.activator, {
      dialog: this,
      text: this.#config.activatorText,
      classes: this.#config.classes?.activator || '',
      $target: $marker
    });

    this.activator = activator.$node;

    $marker.remove();
  }

}


module.exports = DialogForm;
