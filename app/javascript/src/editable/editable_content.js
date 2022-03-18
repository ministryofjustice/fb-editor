/* Editable Content:
 * Used for creating complex content control objects on HTML areas such as a <DIV>,
 * or <article>. The content will, when in edit mode, convert to Markdown and expect
 * user input in as Markdown. On exit of edit mode visible content will be translated
 * back into HTML for non-edit view and to save.
 * (Edit mode controlled by focus and blur events).
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 **/
const {
  convertToHtml,
  convertToMarkdown,
  sanitiseHtml,
} = require('./editable_utilities');

const EditableElement = require('./editable_element');

class EditableContent extends EditableElement {
  constructor($node, config) {
    super($node, config);
    var $input = $("<textarea class=\"input\"></textarea>");
    var $output = $("<div class=\"output\"></div>");
    var $span = $("<span>measure</span>");
    var lineHeight;

    // ??
    $span.css({
      font: "inherit",
      visibility: "hidden"
    });

    $node.append($span);
    lineHeight = $span.height();
    $span.remove();

    // Use a textarea for input because it is more predictable than
    // using a div with contentEditable attribute.
    $output.append($node.html());
    $node.empty();
    $node.append($input);
    $node.append($output);

    // Clear inherited events
    $node.off("blur.editablecomponent");
    $node.off("focus.editablecomponent");
    $node.off("paste.editablecomponent");
    $node.off("keydown.editablecomponent");
    $node.attr("contentEditable", false);

    // Add event to required element
    $output.on("click.editablecontent, focus.editablecontent", this.edit.bind(this) );
    $input.on("blur.editablecontent", this.update.bind(this) );
    // TODO: Experimental and not quite working properly auto-resizing effort.
    //       Disabled for MVP unless there is time to get it right.
    //$input.on("keydown.editablecontent, paste.editablecontent", EditableContent.inputResizer.bind(this) );

    // Correct the class:
    $node.removeClass("EditableElement");
    $node.addClass("EditableContent");

    if(config.text.default_content) {
      this._defaultContent = config.text.default_content;
    }

    this._editing = false;
    this._content = convertToMarkdown($output.html().trim()); // trim removes whitespace from template.
    this._lineHeight = lineHeight;
    this.$input = $input;
    this.$output = $output;
  }

  /* Experimental effort to auto-resize input area.
   * Currently not used as not working 100%.
   **/
  #inputResizer(e) {
    if(e.which == 13) {
      this.$input.height(this.$input.height() + this._lineHeight);
    }
  }

  // Get content must always return Markdown because that's what we save.
  get content() {
    var content = this._content;
    var contentWithoutWhitespace = content.replace(/\s/mig, "");
    var defaultWithoutWhitespace = this._defaultContent.replace(/\s/mig, "");

    // Remove whitespace for better comparison
    content = (contentWithoutWhitespace == defaultWithoutWhitespace ? "" : content);

    // Bit hacky but we handle one type of content value as a string (see above),
    // and the other (component) content as a JSON string for all the component data.
    if(this._config.data) {
      this._config.data.content = content;
      content = JSON.stringify(this._config.data);
    }

    return content;
  }

  set content(markdown) {
    this._content = markdown;
    this.emitSaveRequired();
  }

  edit() {
    this.$node.addClass(this._config.editClassname);
    this.$input.val(this._content); // Adds latest stored content to input area
    this.$input.focus();
    this.$input.select();
  }

  focus() {
    this.edit();
  }

  update() {
    this.content = sanitiseHtml(this.$input.val().trim()); // Get the latest markdown
    this.$node.removeClass(this._config.editClassname);

    // Figure out what content to show
    let defaultContent = this._defaultContent || this._originalContent;
    let content = (this._content == "" ? defaultContent : this._content);

    // Add latest content to output area
    this.$output.html(convertToHtml(content));
  }
}

module.exports = EditableContent;
