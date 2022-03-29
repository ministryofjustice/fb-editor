
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
import { EditableCollectionFieldComponent } from './editable_collection_field_component';
import { EditableContent } from './editable_content';
import { EditableElement } from './editable_element';
import { EditableGroupFieldComponent } from './editable_group_field_component';
import { EditableTextFieldComponent } from './editable_text_field_component';
import { EditableTextareaFieldComponent } from './editable_textarea_field_component';

/* Determine what type of node is passed and create editable content type
 * to match.
 *
 * @$node ($jQuery node) REQUIRED - jQuery wrapped HTML element to become editable content.
 * @config (Object) Properties passed for any configuration.
 **/
export function editableComponent($node, config) {
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

