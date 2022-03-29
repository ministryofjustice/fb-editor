/* Editable Component Collection Item:
 * Used for things like Radio Options/Checkboxes that have a label and hint element
 * but are owned by a parent Editable Component, so does not need to save their
 * own content by writing a hidden element (like other types). Not considered
 * a standalone 'type' to be used in the editableComponent() initialisation
 * function.
 *
 * Save function will produce a JSON string as content from internal data object
 * but do nothing else with it. A parent component will read and use the
 * generated 'saved' content.
 *
 * config.onItemRemoveConfirmation (Function) An action passed the item.
 *
 **/
const {
  mergeObjects,
  safelyActivateFunction,
} = require('../utilities'); 

import { createEditableCollectionItemMenu } from './editable_utilities';

import { EditableComponentBase } from './editable_component_base';

export class EditableComponentCollectionItem extends EditableComponentBase {
  constructor(editableCollectionFieldComponent, $node, config) {
    super($node, mergeObjects({
      selectorElementLabel: config.selectorComponentCollectionItemLabel,
      selectorElementHint: config.selectorComponentCollectionItemHint
    }, config));

    this.menu = createEditableCollectionItemMenu(this, config);

    $node.on("focus.EditableComponentCollectionItem", "*", function() {
      $node.addClass(config.editClassname);
    });

    $node.on("blur.EditableComponentCollectionItem", "*", function() {
      $node.removeClass(config.editClassname);
    });

    this.component = editableCollectionFieldComponent;
    $node.addClass("EditableComponentCollectionItem");
  }

  remove() {
    if(this._config.onItemRemoveConfirmation) {
      // If we have confirgured a way to confirm first...
      safelyActivateFunction(this._config.onItemRemoveConfirmation, this);
    }
    else {
      // or just run the remove function.
      this.component.removeItem(this);
    }
  }

  save() {
    // Doesn't need super because we're not writing to hidden input.
    this.content = this._elements;
  }

}
