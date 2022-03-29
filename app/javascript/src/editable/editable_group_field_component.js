/* Editable Group Field Component:
 * Structured editable component comprising of one or more fields wrapped in fieldset.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Example expected backend structure  (passed as JSON - using a Date component)
 * -----------------------------------------------------------------------------
 *  _id: Date_date_1
 *  hint: Component hint
 *  name: Date_date_1
 *  _type: date
 *  label: Component label
 *  errors: {}
 *  validation:
 *    required: true
 *
 * Expected (minimum) frontend struture
 * ------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="date" data-fb-conent-data=" ...JSON... ">
 *   <fieldset>
 *     <legend>Question text</legend>
 *
 *     <label>Day</label>
 *     <input name="answers[date_1]" type="text" />
 *
 *     <label>Month</label>
 *     <input name="answers[date_2]" type="text" />
 *
 *     <label>Year</label>
 *     <input name="answers[date_3]" type="text" />
 *   </fieldset>
 * </div>
 **/
const { mergeObjects } = require('../utilities');
import { EditableComponentBase } from './editable_component_base';

export class EditableGroupFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, mergeObjects({
      selectorElementLabel: config.selectorLabel,
      selectorElementHint: config.selectorHint
    }, config));
    $node.addClass("EditableGroupFieldComponent");
  }

  // Override get/set content only because we need to use data.legend instead of data.label
  get content() {
    return JSON.stringify(this.data);
  }

  set content(elements) {
    this.data.legend = elements.label.content;
    this.data.hint = elements.hint.content;
  }
}
