/* Editable Base:
 * Shared code across the editable component types.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options, e.g.
 *                  {
 *                    editClassname: 'usedOnElementToShowEditing'
 *                    form: $formNodeToAddHiddenInputsForSaveSubmit,
 *                    id: 'identifierStringForUseInHiddenFormInputName',
 *                    type: 'editableContentType'
 *                  }
 **/
const { 
  addHiddenInputElementToForm, 
  updateHiddenInputOnForm 
} = require('../utilities');

export class EditableBase {
  constructor($node, config) {
    this._config = config || {};
    this.type = config.type;
    this.$node = $node;
    $node.data("instance", this);
    $node.on("click.editablecomponent focus.editablecomponent", (e) => {
      e.preventDefault();
    });
  }

  get content() {
    return $node.text();
  }

  remove() {
    // 1. Remove any form element with target name.
    // 2. Add uuid of target component to delete_components array.
    var $input = $(this._config.form).find("[name='" + this._config.id + "']")
    if($input.length) {
      $input.remove();
    }
    addHiddenInputElementToForm(this._config.form, "delete_components[]", this._config.data._uuid);
  }

  save() {
    updateHiddenInputOnForm(this._config.form, this._config.id, this.content);
  }

  emitSaveRequired() {
    $(document).trigger("SaveRequired");
  }
}
