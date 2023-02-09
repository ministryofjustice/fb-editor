const { EditableCollectionFieldComponent } = require('../../../app/javascript/src/editable_components');
const GlobalHelpers = require('../../helpers');

const constants = {
  EDIT_CLASSNAME: 'editable-editing',
  SELECTOR_LABEL: '.editable-label',
  SELECTOR_HINT: '.editable-hint',
  SELECTOR_ITEM: '.editable-collection-item',
  SELECTOR_ITEM_LABEL: '.editable-collection-item-label',
  SELECTOR_ITEM_HINT: '.editable-collection-item-hint',
  COMPONENT_UUID: '5653-2378-7382-2376'
}

function createEditableCollectionFieldComponent(id, config, itemCount=3, type="checkbox") {
  var html = `
      <form id="${id}-form">
      </form>

    <div id="${id}">
      <fieldset>
        <legend class="editable-label">Legend</legend>
        <div class="editable-hint">Hint</div>
        <div class="editable-collection-items">

        </div>
      </fieldset>
    </div>
  `;

  $(document.body).append(html);

  let itemHtml = ``;
  let itemData = [];

  for(i=0; i < itemCount; i++ ) {
    itemHtml += `
      <div class="editable-collection-item">
        <input class="" id="item_${i}" name="item_${i} type="${type}" value="value_${i}">
        <label class="editable-collection-item-label" for="item_${i}">
          Label for Item ${i}
        </label>
        <div id="item_${i}_hint" class="editable-collection-item-hint">
          Hint for Item ${i}
        </div>
      </div>
    `;
    itemData.push({
      _uuid: '1234567890-'+i,
      _id: 'item_'+i,
      value: 'value_'+i,
    })
  }


  $('.editable-collection-items').append(itemHtml);

  $node = $(document).find('#'+id);
  $form = $(document).find('#'+id+'-form');

  var conf = {
    editClassname: constants.EDIT_CLASSNAME,
    form: $form,
    id: id,
    type: 'editable-type',
    data: {
      _uuid: constants.COMPONENT_UUID,
      items: itemData,
    },
    text: {
      edit: 'Edit',
    },
    selectorElementLabel: constants.SELECTOR_LABEL,
    selectorElementHint: constants.SELECTOR_HINT,
    selectorCollectionItem: constants.SELECTOR_ITEM,
    selectorCollectionItemLabel: constants.SELECTOR_ITEM_LABEL,
    selectorCollectionItemHint: constants.SELECTOR_ITEM_HINT,
  }
  // include any passed config items.
  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }


  var created = new EditableCollectionFieldComponent($node, conf);

  return {
    instance: created,
    $node: $node,
  }
}

function createEditableRadiosComponent(id, config) {
  var conf = {
    type: 'radios'
  }

  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  return createEditableCollectionFieldComponent(id, conf, 3, "radio");
}

function teardownView(id) {
    $("#" + id).remove();
}

module.exports = {
  constants: constants,
  createEditableCollectionFieldComponent: createEditableCollectionFieldComponent,
  createEditableRadiosComponent: createEditableRadiosComponent,
  teardownView: teardownView,
}




