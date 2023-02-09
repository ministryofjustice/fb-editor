require('../../setup');

describe('EditableCollectionFieldComponment', function() {
  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = 'editable-collection-field-componnetn-methods-test';

  describe('Methods', function() {
    var sandbox;

    beforeEach(function() {
      sandbox = sinon.createSandbox();
    });

    afterEach(function() {
      sandbox.restore();
      helpers.teardownView(COMPONENT_ID);
    });

    describe('canHaveItemsRemoved()', function() {
      it('returns true if items is greater than preservedItemCount', function() {
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID, {}, 3);

        expect(created.instance.canHaveItemsRemoved()).to.be.true;
      })

      it('returns false if items is equal to preservedItemCount', function() {
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID, {}, 1);

        expect(created.instance.canHaveItemsRemoved()).to.be.false;
      })
    });

    describe('addItem()', function() {
      it('adds a new item', function(){
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID, {}, 3);
        expect(created.instance.items.length).to.equal(3);

        created.instance.addItem();
        expect(created.instance.items.length).to.equal(4);
      });

      it('updates the item data', function() {
        var filters = {
          _id: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          },
          value: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          }
        }
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID, {filters: filters}, 3);

        created.instance.items.forEach((item, idx) => {
          expect(item.data._id).to.equal('item_'+idx)
          expect(item.data.value).to.equal('value_'+idx)
        });

        created.instance.addItem();

        created.instance.items.forEach((item, idx) => {
          expect(item.data._id).to.equal('item_'+(idx+1))
          expect(item.data.value).to.equal('value_'+(idx+1))
        });
      });

      it('triggers the saveRequired event', function() {
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID);
        var itemToRemove = created.instance.items[1];
        var eventCount = 0;

        $(document).on('SaveRequired', function() {
          eventCount++;
        });


        created.instance.addItem();
        expect(eventCount).to.equal(1);
      })
    });

    describe('removeItem()', function(){

      it('removes the item', function() {
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID, {}, 4)
        var itemToRemove = created.instance.items[1];
        var remainingItems = [created.instance.items[0], created.instance.items[2], created.instance.items[3]];
        expect(created.instance.items.length).to.equal(4);

        created.instance.removeItem(itemToRemove);

        expect(created.instance.items.length).to.equal(3);
        expect(created.instance.items).to.not.include(itemToRemove);
        expect(created.instance.items).to.eql(remainingItems);
      });


      it('updates the item data', function() {
        var filters = {
          _id: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          },
          value: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          }
        }
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID, {filters: filters}, 5);
        var itemToRemove = created.instance.items[2];

        created.instance.items.forEach((item, idx) => {
          expect(item.data._id).to.equal('item_'+idx)
          expect(item.data.value).to.equal('value_'+idx)
        });

        created.instance.removeItem(itemToRemove);

        created.instance.items.forEach((item, idx) => {
          expect(item.data._id).to.equal('item_'+(idx+1))
          expect(item.data.value).to.equal('value_'+(idx+1))
        });
      });

      it('triggers the saveRequired event', function() {
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID);
        var itemToRemove = created.instance.items[1];
        var eventCount = 0;

        $(document).on('SaveRequired', function() {
          eventCount++;
        });

        created.instance.removeItem(itemToRemove);
        expect(eventCount).to.equal(1);
      })
    });

    describe('save()', function() {
      it('calls save on each EditableCollectionItem', function(){
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID);
        var spies = [];
        created.instance.items.forEach( (item, idx) => {
          spies.push(sinon.spy(item));
        });

        created.instance.save();

        spies.forEach((spy) => {
          expect(spy.save).to.have.been.calledOnce;
        });
      });
    });

    describe('set content()', function() {
      it('should set the instance data', function() {
        var created = helpers.createEditableCollectionFieldComponent(COMPONENT_ID);
        var elements = created.instance._elements;

        created.instance.content = elements;

        expect(created.instance.data).to.include.keys(['legend', 'hint', 'items']);
        expect(created.instance.data.items.length).to.equal(created.instance.items.length);
        created.instance.data.items.forEach( (item, idx) => {
          expect(item).to.eql({
            _uuid: '1234567890-'+idx,
            _id: 'item_'+idx,
            value: 'value_'+idx,
          });
        });
      });
    });

  });
})
