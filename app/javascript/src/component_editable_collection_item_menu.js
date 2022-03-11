
/**
 * Activated Editable Collection Item Menu Component
 * ----------------------------------------------------
 * Description:
 * Enhances Activated Menu component for specific Editable Collection Item Menu.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/menu
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const ActivatedMenu = require('./component_activated_menu');
const DialogApiRequest = require('./component_dialog_api_request');


class EditableCollectionItemMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      activator_text: "",
      $target: $(), // Used in placing the activator
      collectionItem: {},
      view: {},
      onSetRequired: function(){} // Called at end of set required function
    }, config));

    $node.on("menuselect", (event, ui) => {
      this.selection(event, ui.item);
    });

    let $target = this._config.$target;
    if($target.length) {
      $target.before(this.activator.$node);
      $target.on("focus.questionmenu", () => this.activator.$node.addClass("active"));
      $target.on("blur.questionmenu", () => this.activator.$node.removeClass("active"));
    }

    this.collectionItem = config.collectionItem;
  }

  selection(event, item) {
    var action = item.data("action");
    this.selectedItem = item;

    event.preventDefault();
    switch(action) {
      case "remove":
           this.remove(item);
           break;
    }
  }

  remove(item) {
    var path = item.data('api-path');
    var collectionItem = this.collectionItem

    var questionUuid =  collectionItem.component.data._uuid;
    var optionUuid =  collectionItem.data._uuid; 

    var url = utilities.stringInject(path, { 
      'question_uuid': questionUuid, 
      'option_uuid': optionUuid ?? 'new', 
    });

    if( !optionUuid ) {
      url = url + '&label=' + encodeURIComponent( collectionItem.$node.find('label').text() );
    }
  
    console.log(url);

    new DialogApiRequest(url, {
      activator: item,
      closeOnClickSelector: ".govuk-button",
      build: function(dialog) {
        dialog.$node.find("[data-method=delete]").on("click", function(e) {
          e.preventDefault();
          collectionItem.component.removeItem(collectionItem)
        })
      }
    })

    //this.collectionItem.remove();
  }
}

module.exports = EditableCollectionItemMenu;
