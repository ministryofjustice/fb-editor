const {
  mergeObjects,
  safelyActivateFunction,
} = require('./utilities');

class Dialog {
  #config;
  #state;
  #className = 'Dialog';
  
  constructor($node, config) {
    this.#config = mergeObjects({
      activator: false,
      autoOpen: false,
      classes: {},
      closeOnClickSelector: 'button[type="button"]',
      confirmOnClickSelector: '',
      onOpen: function(dialog) {},
      onClose: function(dialog) {},
    }, config);

    this.#state = 'closed';
    this.$node = $(); // Should be overwritten once intialised
    this.$container = $(); // Should be overwritten once intialised

    this.initialize($node);
  }

  get state(){
    return this.state;
  }

  isOpen() {
    return this.#state == 'open';
  }

  open() {
    var dialog = this;
    this.$node.dialog('open');
    this.#state = "open";
    safelyActivateFunction(this.#config.onOpen, dialog);
    queueMicrotask(() => {
      dialog.focus();
    })
  }

  close() {
    var dialog = this;
    if(this.activator) {
      this.activator.$node.focus();
    }
    this.$node.dialog('close');
    this.#state = 'closed';
    safelyActivateFunction(this.config.onclose, dialog);
  }

  focus() {
    el = this.$node.parent().find('button:not([type="disabled"])').not(".ui-dialog-titlebar-close").eq(0);
    if(el){
      el.focus();
    }
  }

  #initialize($node) {
    this.$node = $node;

    this.#build();

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
