const { createEditableCollectionFieldComponent } = require('./helpers');
const { EditableComponentCollectionItem } = require('../../../app/javascript/src/editable_components');

require('../../setup');

describe('EditableCollectionFieldComponent', function() {
  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = 'editable-collection-field-component-properties-test';

  describe('Properties', function() {

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
    });

    describe('items', function() {
      var created;

      beforeEach(function() {
        created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID);
      });

      it('should have a public items property', function() {
        expect(created.instance.items).to.exist;
        expect(created.instance.items).to.be.an('array');
        expect(created.instance.items.length).to.equal(3);
      });

      it('should contain the correct number of items', function() {
        helpers.teardownView(COMPONENT_ID);
        created = createEditableCollectionFieldComponent(COMPONENT_ID, {}, 2);

        expect(created.instance.items.length).to.equal(2);
      });

      it('should contain EditableCollectionItem instances', function() {
        created.instance.items.forEach((item) => {
          expect(item).to.be.an.instanceof(EditableComponentCollectionItem);
        })
      });

      it('should initialise EditableCollectionItems with config', function() {
        created.instance.items.forEach((item) => {
          expect(item.config).to.exist
          expect(item.config).to.not.have.any.keys([ 'items' ]);
          expect(item.config).to.include.keys([ 'preserveItem' ]);
          expect(item.config.data).to.include.all.keys([ '_uuid', '_id', 'value' ]);
          expect(item.config.data._uuid).to.not.equal(c.COMPONENT_UUID);
        });
      });

      it('should set config.preserveItem correctly for checkboxes', function() {
        expect(created.instance.items[0].config.preserveItem).to.be.true;
        expect(created.instance.items[1].config.preserveItem).to.be.false;
      });

      it('should set config.preserveItem key correctly for radios', function() {
        helpers.teardownView(COMPONENT_ID)
        created = helpers.createEditableRadiosComponent(COMPONENT_ID);

        expect(created.instance.items[0].config.preserveItem).to.be.true;
        expect(created.instance.items[1].config.preserveItem).to.be.true;
        expect(created.instance.items[2].config.preserveItem).to.be.false;
      });
    });

    describe('$itemTemplate', function() {
      var created;

      beforeEach(function() {
        created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID);
      });

      it('should have an $itemTemplate property', function() {
        expect(created.instance.$itemTemplate).to.exist;
      });

      it('should be different to the first item', function() {
        var $firstItem = created.instance.$node.find(c.SELECTOR_ITEM).first();

        expect(created.instance.$itemTemplate).to.not.equal($firstItem);
      });

      it('should have config data', function() {
          expect(created.instance.$itemTemplate.data('config')).to.exist;
        var templateConfig = created.instance.$itemTemplate.data('config');
          expect(templateConfig).to.not.have.any.keys([ 'items' ]);
          expect(templateConfig.data).to.not.have.any.keys([ '_uuid' ]);
      });
    });
  });
});
