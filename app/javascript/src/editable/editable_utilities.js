
const EditableCollectionItemMenu = require('../component_editable_collection_item_menu');
const showdown  = require('showdown');
const converter = new showdown.Converter({
                    noHeaderId: true,
                    strikethrough: true,
                    omitExtraWLInCodeBlocks: true,
                    simplifiedAutoLink: false,
                    tables: true,
                    disableForced4SpacesIndentedSublists: true
                  });
const { uniqueString } = require('../utilities');

showdown.setFlavor('github');

// This shouldn't be here!
function createEditableCollectionItemMenu(item, config) { 
  var template = $("[data-component-template=EditableCollectionItemMenu]");
  var $ul = $(template.html());

  item.$node.append($ul);
  
  return new EditableCollectionItemMenu($ul, {
      activator_text: config.text.edit,
      container_id: uniqueString("activatedMenu-"),
      collectionItem: item,
      view: config.view,
      menu: {
        position: { my: "left top", at: "right-15 bottom-15" } // Position second-level menu in relation to first.
      }
    });
}

/* Convert Markdown to HTML by tapping into third-party code.
 * Includes clean up of both Markdown and resulting HTML to fix noticed issues.
 **/
function convertToHtml(markdown) {
  var html = converter.makeHtml(markdown);
  html = sanitiseHtml(html);
  return html;
}

/* Convert HTML to Markdown by tapping into third-party code.
 * Includes clean up of HTML by stripping attributes and unwanted trailing spaces.
 **/
function convertToMarkdown(html) {
  var cleaned = sanitiseHtml(html);
  var markdown = converter.makeMarkdown(cleaned);
  return sanitiseMarkdown(markdown);
}

/* Extremely simple function to safely convert target elements, 
 * such as <script>, so JS doesn't run in editor.
 * Note: Because we're converting from Markup, we need to be
 * careful about what is converted into entity or escaped form.
 * For that reason, we are trying to be minimalistic in approach.
 **/ 
function sanitiseHtml(html) {
  html = html.replace(/<([\/\s])?script[^\<\>]*?>/mig, "&lt;$1script&gt;");
  return html;
}

/* Opportunity safely strip out anything that we don't want here.
 * 1. Something in makeMarkdown is adding <!-- --> markup to the result so we're trying to get rid of it.
 * 2. ...
 **/
function sanitiseMarkdown(markdown) {
  markdown = markdown.replace(/\n<!--.*?-->/mig, "");
  return markdown;
}


/* Single Line Input Restrictions
 *Browser contentEditable mode means some pain in trying to prevent
 * HTML being inserted (rich text attempts by browser). We're only
 * editing as plain text and markdown for all elements so try to
 * prevent unwanted entry with this function.
 **/
function singleLineInputRestrictions(event) {

  // Prevent ENTER adding <div><br></div> nonsense.
  if(event.which == 13) {
    event.preventDefault();
  }
}

/* Function prevents rich text being pasted on paste event.
 * Used in the editing markdown area so we do not get crossed
 * formats.
 *
 * Use like: $('something').on('paste', e => pasteAsPlainText(e) )}
 **/
function pasteAsPlainText(event) {
  event.preventDefault();
  var content = "";
  if (event.clipboardData || event.originalEvent.clipboardData) {
    content = (event.originalEvent || event).clipboardData.getData('text/plain');
  }
  else {
    if (window.clipboardData) {
      content = window.clipboardData.getData('Text');
    }
  }

  if (document.queryCommandSupported("insertText")) {
    document.execCommand("insertText", false, content);
  }
  else {
    document.execCommand("paste", false, content);
  }
}

module.exports = {
  convertToHtml: convertToHtml,
  convertToMarkdown: convertToMarkdown,
  createEditableCollectionItemMenu: createEditableCollectionItemMenu,
  sanitiseHtml: sanitiseHtml,
  sanitiseMarkdown: sanitiseMarkdown,
  singleLineInputRestrictions: singleLineInputRestrictions,
  pasteAsPlainText: pasteAsPlainText,
}
