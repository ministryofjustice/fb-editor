/* Editable Element:
 * Used for creating simple content control objects on HTML
 * elements such as <H1>, <P>, <LABEL>, <LI>, etc.
 * Switched into edit mode on focus and out again on blur.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options
 **/
const {
  pasteAsPlainText,
  singleLineInputRestrictions,
} = require('./editable_utilities');

const EditableBase = require('./editable_base');

class EditableElement extends EditableBase {
  constructor($node, config) {
    super($node, config);
    var originalContent = $node.text().trim(); // Trim removes whitespace from template.
    var defaultContent = $node.data(config.attributeDefaultText);
    var required = defaultContent === undefined;

    $node.on("blur.editablecomponent", this.update.bind(this));
    $node.on("focus.editablecomponent", this.edit.bind(this) );
    $node.on("paste.editablecomponent", e => pasteAsPlainText(e) );
    $node.on("keydown.editablecomponent", e => singleLineInputRestrictions(e) );

    $node.attr("contentEditable", true);
    $node.attr("role", "textbox"); // Accessibility helper.
    $node.addClass("EditableElement");

    this._content = $node.text().trim();
    this._originalContent = originalContent;
    this._defaultContent = defaultContent;
    this._required = required;
  }

  get content() {
    var content;
    if(this._required) {
      content = (this._content == "" ? this._originalContent : this._content);
    }
    else {
      content = (this._content == this._defaultContent ? "" : this._content);
    }
    return content;
  }

  set content(content) {
    var trimmedContent = content.trim();
    if(this._content != trimmedContent) {
      this._content = trimmedContent;

      // If something changed...
      if(this._content != this._defaultContent && this._content != this._originalContent) {
        this.emitSaveRequired();
      }
    }

    this.populate(content);
  }

  edit() {
    this.$node.addClass(this._config.editClassname);
  }

  update() {
    this.content = this.$node.text().trim();
    this.$node.removeClass(this._config.editClassname);
  }

  // Expects content or blank string to show content or default text in view.
  populate(content) {
    var defaultContent = this._defaultContent || this._originalContent;
    this.$node.text(content == "" ? defaultContent : content);
  }

  focus() {
    this.$node.focus();
  }
}

module.exports = EditableElement;
