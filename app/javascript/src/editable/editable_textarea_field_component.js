/* Editable Textarea Field Component:
 * Structured editable component comprising of one or more elements.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Expected backend structure  (passed as JSON)
 * --------------------------------------------
 *  _id: single-question_textarea_1
 *  hint: Component hint
 *  name: single-question_textarea_1
 *  _type: text
 *  label: Component label
 *  errors: {}
 *  validation:
 *    required: true
 *
 * Expected (minimum) frontend struture
 * ------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="text" data-fb-conent-data=" ...JSON... ">
 *   <label>Component label</label>
 *   <span>Component hint</span>
 *   <textarea name="answers[single-question_textarea_1]"></textarea>
 * </div>
 **/
const { mergeObjects } = require('../utilities');
const EditableComponentBase = require('./editable_component_base');

class EditableTextareaFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, mergeObjects({
      selectorElementLabel: config.selectorLabel,
      selectorElementHint: config.selectorHint
    }, config));
    $node.addClass("EditableTextareaFieldComponent");
  }
}

module.exports = EditableTextareaFieldComponent;
