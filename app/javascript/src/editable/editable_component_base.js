/* Editable Component Base:
 * Share code across the editable component types.
 * Those types are comprised of one or more elements and
 * produce a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 * @elements (Object) Collection of EditableElement instances found in the component.
 *
 **/

const EditableBase = require('./editable_base');

class EditableComponentBase extends EditableBase {
  constructor($node, config, elements) {
    super($node, config);
    this.data = config.data;
    $node.data("instance", this);

    // e.g. elements = {
    //        something: new EditableElement($node.find("something"), config)
    //        and any others...
    //      }
    this._elements = arguments.length > 2 && elements || {
      label: new EditableElement($node.find(config.selectorElementLabel), config),
      hint: new EditableElement($node.find(config.selectorElementHint), config)
    };

    $node.find(config.selectorDisabled).attr("disabled", true); // Prevent input in editor mode.
  }

  get content() {
    return JSON.stringify(this.data);
  }

  set content(elements) {
    // Expect this function to be overridden for each different type inheriting it.
    // e.g.
    // this.data.something = elements.something.content
    this.data.label = elements.label.content;
    this.data.hint = elements.hint.content;
  }

  save() {
    // e.g.
    // this.data.something = this._elements.something.content;
    this.content = this._elements;
    EditableBase.prototype.save.call(this);
  }

  // Focus on first editable element.
  focus() {
    for(var i in this._elements) {
      if(this._elements.hasOwnProperty(i)) {
        this._elements[i].focus();
        break;
      }
    }
  }
}

module.exports = EditableComponentBase;
