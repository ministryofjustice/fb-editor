
const {
  mergeObjects,
  createElement,
} = require('../utilities');

export class EditableCollectionItemInjector {
  constructor(editableCollectionFieldComponent, config) {
    var conf = mergeObjects({}, config);
    var text = mergeObjects({ itemAdd: 'add' }, config.text);
    var $node = $(createElement("button", text.itemAdd, conf.classes));
    editableCollectionFieldComponent.$node.append($node);
    $node.addClass("EditableCollectionItemInjector");
    $node.attr("type", "button");
    $node.data("instance", this);
    $node.on("click", function(e) {
      e.preventDefault();
      editableCollectionFieldComponent.addItem();
    });

    this.component = editableCollectionFieldComponent;
    this.$node = $node;
  }
}

