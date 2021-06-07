/**
 * Content
 * ----------------------------------------------------
 * Description:
 * Basic construct of a standard content component
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const editableComponent = require('./editable_components').editableComponent;
const ContentMenu = require('./component_activated_content_menu');

const ATTRIBUTE_DEFAULT_TEXT = "fb-default-text";


class Content {
  constructor($node, config) {
    var conf = mergeObjects({
      // Config defaults
      attributeDefaultText: ATTRIBUTE_DEFAULT_TEXT,
      data: $node.data("fb-content-data"), // TODO: Phase this out because Question should control data
      editClassname: "active",
      id: $node.data("fb-content-id"),
      text: {},
      type: $node.data("fb-content-type"),
    }, config);

    $node.addClass("Content");
    this._config = conf;
    this.data = $node.data("fb-content-data");
    this.$node = $node;
    this.editable = editableComponent($node, conf);
    this.menu = createContentMenu.call(this);
  }

  focus() {
    this.editable.focus();
  }

  remove() {
    // TODO: Replace with proper mechanism to remove this workaround
    this.editable.remove();
  }

  save() {
    // TODO: Replace with proper mechanism to remove this workaround
    this.editable.save();
  }
}


/* Create a menu for Content property editing.
 **/
function createContentMenu() {
  var component = this;
  var template = $("[data-component-template=ContentMenu]");
  var $ul = $(template.html());

  // Need to make sure $ul is added to body before we try to create a ContentMenu out of it.
  $(document.body).append($ul);

  return new ContentMenu(component, $ul, {
    activator_text: template.data("activator-text")
  });
}



module.exports = Content;
