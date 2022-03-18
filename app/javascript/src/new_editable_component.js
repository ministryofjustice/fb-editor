
/**
 * Editable Components
 * ----------------------------------------------------
 * Description:
 * Enhance target elements (components) with editable update/save properties.
 *
 * Requires: jQuery
 * Documentation:
 *
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const createElement = utilities.createElement;
const uniqueString = utilities.uniqueString;
const safelyActivateFunction = utilities.safelyActivateFunction;
const addHiddenInpuElementToForm = utilities.addHiddenInpuElementToForm;
const updateHiddenInputOnForm = utilities.updateHiddenInputOnForm;
const showdown  = require('showdown');
const converter = new showdown.Converter({
                    noHeaderId: true,
                    strikethrough: true,
                    omitExtraWLInCodeBlocks: true,
                    simplifiedAutoLink: false,
                    tables: true,
                    disableForced4SpacesIndentedSublists: true
                  });
const EditableCollectionItemMenu = require('./component_editable_collection_item_menu');

const EditableBase = require('./editable/editable_base');
const EditableCollectionFieldComponent = require('./editable/editable_collection_field_component');
const EditableCollectionItemInjector = require('./editable/editable_collection_item_injector');
const EditableComponentBase = require('./editable/editable_component_base');
const EditableContent = require('./editable/editable_content');
const EditableElement = require('./editable/editable_element');
const EditableGroupFieldComponent = require('./editable/editable_group_field_component');
const EditableTextFieldComponent = require('./editable/editable_text_field_component');
const EditableTextAreaComponent = require('./editable/editable_textarea_field_component');

showdown.setFlavor('github');




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

/* Convert Markdown to HTML by tapping into third-party code.
 * Includes clean up of both Markdown and resulting HTML to fix noticed issues.
 **/
function convertToHtml(markdown) {
  var html = converter.makeHtml(markdown);
  html = sanitiseHtml(html);
  return html;
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


/* Determin what type of node is passed and create editable content type
 * to match.
 *
 * @$node ($jQuery node) REQUIRED - jQuery wrapped HTML element to become editable content.
 * @config (Object) Properties passed for any configuration.
 **/
function editableComponent($node, config) {
  var klass;
  switch(config.type) {
    case "element":
      klass = EditableElement;
      break;
    case "content":
      klass = EditableContent;
      break;
    case "text":
    case "email":
    case "number":
    case "upload":
      klass = EditableTextFieldComponent;
      break;
    case "textarea":
      klass = EditableTextareaFieldComponent;
      break;
    case "date":
      klass = EditableGroupFieldComponent;
      break;
    case "radios":
    case "checkboxes":
      klass = EditableCollectionFieldComponent;
      break;
  }
  return new klass($node, config);
}


// Make available for importing.
module.exports =  {
  editableComponent: editableComponent,
}
