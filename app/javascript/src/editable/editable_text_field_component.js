/* Editable Text Field Component:
 * Structured editable component comprising of one or more elements.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Expected backend structure  (passed as JSON)
 * --------------------------------------------
 *  _id: single-question_text_1
 *  hint: Component hint
 *  name: single-question_text_1
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
 *   <input name="answers[single-question_text_1]" type="text">
 * </div>
 **/
const EditableComponentBase = require('./editable_component_base');

class EditableTextFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    // TODO: Potential future addition...
    //       Maybe make this EditableAttribute instance when class is
    //       ready so we can edit attribute values, such as placeholder.
    //  {input: new EditableAttribute($node.find("input"), config)}
    super($node, mergeObjects({
      selectorElementLabel: config.selectorLabel,
      selectorElementHint: config.selectorHint
    }, config));
    $node.addClass("EditableTextFieldComponent");
  }
}
