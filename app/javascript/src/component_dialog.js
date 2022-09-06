const {
  mergeObjects,
  safelyActivateFunction,
} = require('./utilities');

const DialogActivator = require('./component_dialog_activator');

class Dialog {
  #className = 'Dialog';
  #config;
  #defaultText = {};
  #elements = {};
  #state;
  
  constructor($node, config) {
    this.#config = mergeObjects({
      activator: false,
      autoOpen: false,
      classes: {},
      closeOnClickSelector: 'button:not([data-node="confirm"])',
      confirmOnClickSelector: 'button[data-node="confirm"]',
      onOpen: function(dialog) {},
      onClose: function(dialog) {},
      onConfirm: function(dialog) {},
      onReady: function(dialog) {},
    }, config);

    this.#state = 'closed';
    this.$node = $(); // Should be overwritten once intialised
    this.$container = $(); // Should be overwritten once intialised

    this.#initialize($node);
  }

  get activator() {
    return this.#config.activator;
  }

  set activator($node) {
    this.#config.activator = $node;
  }

  set confirmAction(action) {
    this.#config.onConfirm = action;
  }

  get state(){
    return this.#state;
  }

  get content() {
    return this.#elements;
  }

  set content(text) {
    let content = mergeObjects(this.#defaultText, text)

    this.#elements.heading.text( content.heading );
    this.#elements.content.html( content.content );
    this.#elements.confirm.text( content.confirm );
    this.#elements.cancel.text( content.cancel );
  }

  isOpen() {
    return this.#state == 'open';
  }

  open(text, callback) {
    const dialog = this;

    this.content = text || {};
    this.$node.dialog('open');
    this.#state = "open";

    safelyActivateFunction(callback || this.#config.onOpen, dialog);

    queueMicrotask(() => {
      dialog.focus();
    });
  }

  close(callback) {
    const dialog = this;

    this.focusActivator(); 

    this.$node.dialog('close');
    this.#state = 'closed';

    safelyActivateFunction(callback || this.#config.onClose, dialog);
  }

  focus() {
    const el = this.$node.find('button:not([type="disabled"]):not([data-method="delete"])').eq(0);
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

  #initialize($node) {
    this.$node = $node;

    this.#build();
    this.#enhance();

    if( this.#config.autoOpen ) {
      this.open();
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
    const dialog = this;

    this.#setElements();
    this.#setDefaultText();

    if(this.#config.closeOnClickSelector) {
      this.#setupCloseButtons();
    }

    if(this.#config.confirmOnClickSelector) {
      this.#setupConfirmButton();
    }

    safelyActivateFunction(dialog.#config.onReady, dialog);
  }

  #setElements() {
    this.#elements = {
      heading: this.$node.find("[data-node='heading']"),
      content: this.$node.find("[data-node='content']"),
      confirm: this.$node.find("[data-node='confirm']"),
      cancel: this.$node.find("[data-node='cancel']"),
    }
  }

  #setDefaultText() {
    this.#defaultText = {
      heading: this.#elements.heading.text(),
      content: this.#elements.content.text(),
      confirm: this.#elements.confirm.text(),
      cancel: this.#elements.cancel.text(),
    }
  }

  /* add event listeners to configured close buttons */
  #setupCloseButtons() {
    const dialog = this;

    if(this.#config.closeOnClickSelector) {
      let $buttons = $(this.#config.closeOnClickSelector, this.$container);
      $buttons.on("click", function() {
        dialog.close();
      });
    } 
  }

  #setupConfirmButton() {
    const dialog = this;
    const $button = $(this.#config.confirmOnClickSelector, this.$container).first();
    $button.on("click", function(e) {
      e.preventDefault(); 
      dialog.close(dialog.confirmAction);
    });
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

module.exports = Dialog;
