const {
  mergeObjects,
  safelyActivateFunction,
} = require('./utilities');

class Dialog {
  #config;
  #state;
  #className = 'Dialog';
  #elements = {};
  #defaultText = {};
  
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

  get state(){
    return this.state;
  }

  get content() {
    return this.#elements || this.#defaultText;
  }

  set content(text) {
    this.#elements.heading.text( text.heading || this.#defaultText.heading );
    this.#elements.content.html( text.content || this.#defaultText.content );
    this.#elements.confirm.text( text.confirm || this.#defaultText.confirm );
    this.#elements.cancel.text( text.cancel || this.#defaultText.cancel );
  }

  isOpen() {
    return this.#state == 'open';
  }

  open(text, action) {
    const dialog = this;
    console.log(text);

    this.content = text || {};
    this.$node.dialog('open');
    this.#state = "open";

    if(action) {
      this.#config.onConfirm = action;
    }
    
    safelyActivateFunction(this.#config.onOpen, dialog);

    queueMicrotask(() => {
      dialog.focus();
    });
  }

  close() {
    const dialog = this;

    if(this.activator) {
      this.activator.$node.focus();
    }

    this.$node.dialog('close');
    this.#state = 'closed';

    safelyActivateFunction(this.#config.onclose, dialog);
  }

  focus() {
    const el = this.$node.parent().find('button:not([type="disabled"]):not([data-method="delete"])').not(".ui-dialog-titlebar-close").eq(0);
    if(el){
      el.focus();
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

    if(this.#config.activator) {
      this.#createActivator();
    }

    this.$node.on("dialogcreate", (event, ui) => {
      this.$container = dialog.$node.parents(".ui-dialog");
      this.$container.addClass(dialog.#className);
    });

    // Add the jQueryUI dialog functionality.
    this.$node.dialog({
      autoOpen: false,
      classes: this.#config.classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
    });
    
    this.$node.data("instance", this);
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
      safelyActivateFunction(dialog.#config.onConfirm, dialog );
      dialog.close();
    });
  }
  
  #createActivator() {
    var $marker = $("<span></span>");

    this.$node.before($marker);
    this.activator = new DialogActivator(this.#config.activator, {
      dialog: this,
      text: this.#config.activatorText,
      classes: this.#config.classes?.activator || '',
      $target: $marker
    });

    $marker.remove();
  }

}

module.exports = Dialog;
