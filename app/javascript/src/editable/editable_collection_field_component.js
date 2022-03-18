/* Editable Collection (Radios/Checkboxes) Field Component:
 * Structured editable component comprising of one or more elements.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Expected backend structure  (passed as JSON)
 * --------------------------------------------
 *  _id: collections_1,
 *  hint: Hint text,
 *  name: collections_1,
 *  _type : [radios|checkboxes],
 *  items: [
 *    {
 *      _id: component_item_1,
 *      hint: Hint text,
 *      _type: [radio|checkbox],
 *      label: Label Text,
 *      value: value-1
 *    },{
 *     _id: component_item_2,
 *      hint: Hint text,
 *      _type: [radio|checkbox],
 *      label: Label text,
 *      value: value-2
 *    }
 *  ],
 *  errors: {},
 *  legend: Question,
 *  validation: {
 *    required: true
 *  }
 *
 *
 * Expected (minimum) frontend structure
 * -------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="radios" data-fb-conent-data=" ...JSON... ">
 *   <fieldset>
 *     <legend>Question</legend>
 *
 *     <input name="answers[single-question_radio_1]" type="radio" />
 *     <label>Component label</label>
 *     <span>Component hint</span>
 *
 *     <input name="answers[single-question_radio_1]" type="radio" />
 *     <label>Component label</label>
 *     <span>Component hint</span>
 *
 * </div>
 **/

const EditableComponentBase = require('./editable_component_base');

class EditableCollectionFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, mergeObjects({
      selectorElementLabel: config.selectorLabel,
      selectorElementHint: config.selectorHint
    }, config));

    var text = config.text || {}; // Make sure it exists to avoid errors later on.
    
    this.items = [];
    this._preservedItemCount = (this.type == "radios" ? 2 : 1); // Either minimum 2 radios or 1 checkbox.
    
    this.#createCollectionItemTemplate(config);
    this.#createEditableCollectionItems(config);

    new EditableCollectionItemInjector(this, config);

    $node.addClass("EditableCollectionFieldComponent");
  }

  // If we override the set content, we obliterate relationship with the inherited get content.
  // This will retain the inherit functionality by explicitly calling it.
  get content() {
    return super.content;
  }

  set content(elements) {
    this.data.legend = elements.label.content;
    this.data.hint = elements.hint.content;

    // Set data from items.
    this.data.items = [];
    for(var i=0; i< this.items.length; ++i) {
      this.data.items.push(this.items[i].data);
    }
  }

 /*
 * Create an item template which can be cloned in component.addItem()
 * config (Object) key/value pairs for extra information.
 *
 * Note: Initial index elements of Array/Collection is called directly
 * without any checking for existence. This is because they should always
 * exist and, if they do not, we want the script to throw an error
 * because it would alert us to something very wrong.
 **/
  #createCollectionItemTemplate(config) {
    var $clone = this.$node.find(config.selectorCollectionItem).eq(0).clone();
    var data = mergeObjects({}, config.data, ["items", "_uuid"]); // pt.1 Copy without items and component uuid.
    var itemConfig = mergeObjects({}, config, ["data"]); // pt.2 Copy without data.
    itemConfig.data = mergeObjects(data, config.data.items[0], "_uuid"); // Bug fix response to JS reference handling.

    // Filters could be changing the blah_1 values to blah_0, depending on filters in play.
    itemConfig.data = this.#applyFilters(config.filters, 0, itemConfig.data);

    // In case we need some custom actions on element.
    safelyActivateFunction(config.onCollectionItemClone, $clone);

    $clone.data("config", itemConfig);

    // Note: If we need to strip out some attributes or alter the template
    //       in some way, do that here.

    this.$itemTemplate = $clone;
  }

   /*
   * Find radio or checkbox items and enhance with editable functionality.
   * Creates the initialising values for this.items
   * config (Object) key/value pairs for extra information.
   **/
    #createEditableCollectionItems(config) {
    var component = this;
    component.$node.find(config.selectorCollectionItem).each(function(i) {
      // WARNING! DO NOT MOVE data or itemConfig OUTSIDE OF THIS LOOP
      // Due to JS reference handling of objects we need to make sure data and itemConfig are
      // inside the loop to instantiate two completely different variables. JS will not pass
      // by value so the alternative is creating EditableCollectionItems that share these objects.
      var data = mergeObjects({}, config.data, ["items", "_uuid"]); // pt.1 Copy without items and component uuid.
      var itemConfig = mergeObjects({ preserveItem: (i < component._preservedItemCount) }, config, ["data"]); // pt.2 Without data
      itemConfig.data = mergeObjects(data, config.data.items[i]); // Bug fix response to JS reference handling.

      // Only wrap in EditableComponentCollectionItem functionality if doesn't look like it has it.
      if(this.className.indexOf("EditableComponentCollectionItem") < 0) {
        var item = new EditableComponentCollectionItem(component, $(this), itemConfig);
        item.menu = createEditableCollectionItemMenu(component, component._config);
        component.items.push(item);
      }
    });
  }

  /*
   * Run through the collection items to make sure data is sync'd when we've
   * either added a new item or removed one (e.g. makes sure to avoid clash
   * of data _id values.
   **/
  #updateItems() {
    var filters = this._config.filters;
    for(var i=0; i < this.items.length; ++i) {
      this.items[i].data = this.#applyFilters(filters, i+1, this.items[i].data);
    }
  }


  /*
   * Applies config.filters to the data passed in, with an index number, since this should
   * be called within a loop of the items. It has been expracted out to counter complications
   * running into closure issues due to manipulating data within a loop.
   * @unique (Integer|String) Should be current loop number, or at least something unique.
   * @data   (Object) Collection item data.
   **/
  #applyFilters(filters, unique, data) {
    var filtered_data = {};
    for(var prop in data) {
      if(filters && filters.hasOwnProperty(prop)) {
        filtered_data[prop] = filters[prop].call(data[prop], unique);
      }
      else {
        filtered_data[prop] = data[prop];
      }
    }
    return filtered_data;
  }

  canHaveItemsRemoved() {
    return this.items.length > this._preservedItemCount;
  }

  // Dynamically adds an item to the components collection
  addItem() {
    // Component should always have at least one item, otherwise something is very wrong.
    var $lastItem = this.items[this.items.length - 1].$node;
    var $clone = this.$itemTemplate.clone();
    $lastItem.after($clone);
    var item = new EditableComponentCollectionItem(this, $clone, this.$itemTemplate.data("config"));
    item.menu = createEditableCollectionItemMenu(this, this._config);
    this.items.push(item);
    this.#updateItems();

    safelyActivateFunction(this._config.onItemAdd, $clone);
    this.emitSaveRequired();
  }

  // Dynamically removes an item to the components collection
  removeItem(item) {
    var index = this.items.indexOf(item);
    safelyActivateFunction(this._config.onItemRemove, item);
    this.items.splice(index, 1);
    item.$node.remove();
    this.#updateItems();
    this.emitSaveRequired();
  }

  save() {
    // Trigger the save action on items before calling it's own.
    for(var i=0; i<this.items.length; ++i) {
      this.items[i].save();
    }
    super.save();
  }
}

module.exports = EditableCollectionFieldComponent;
