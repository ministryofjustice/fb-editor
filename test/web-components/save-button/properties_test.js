require('../../setup');
const {
  createComponent,
  createTemplate,
  getElements,
  cleanBody 
} = require('./helpers')

const { SaveButton } = require( '../../../app/javascript/src/web-components/save-button')
const ID = 'save-button-component-properties-form'

describe('save-button', function() {
  let form, saveButton, input;
    
  before(function() {
    if(!window.customElements.get('save-button')) {
      window.customElements.define('save-button', SaveButton, {extends: 'button'})
    }
  })

  afterEach(function() {
    saveButton = form = input = description = undefined
    cleanBody()
  })
  
  describe('Properties', function(){
    
    describe('with no attributes', function(){

      beforeEach(async function() {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`) 
        await createComponent(form);
        ({saveButton, form, input} = getElements());
      });

      describe('type', function() {
        it('should be a submit', function(){
          expect(saveButton.getAttribute('type')).to.eq('submit')
          expect(saveButton.type).to.eq('submit')
        })
      })

      describe('describedBy', function(){
        it('should be null', function() {
          expect(saveButton.describedBy).to.be.null
        });
      })

      describe('saveRequired', function(){
        it('should be false', function() {
          expect(saveButton.saveRequired).to.be.false
        });
      })

      describe('preventUnload', function(){
        it('should be false', function() {
          expect(saveButton.preventUnload).to.be.false
        });
      })
    })

    describe('with attributes', function(){

      beforeEach(async function() {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`) 
        await createComponent(form, {
          'type': 'button',
          'prevent-unload': true,
          'save-required': true,
          'data-assistive-text': 'assistive text'
        });
        ({saveButton, form, input} = getElements());
      });

      describe('type', function() {
        it('should be a submit', function(){
          expect(saveButton.getAttribute('type')).to.eq('submit')
          expect(saveButton.type).to.eq('submit')
        })
      })

      describe('describedBy', function(){
        it('should be null', function() {
          expect(saveButton.describedBy).to.exist
        });
      })

      describe('saveRequired', function(){
        it('should be true', function() {
          expect(saveButton.saveRequired).to.be.true
        });
      })

      describe('preventUnload', function(){
        it('should be false', function() {
          expect(saveButton.preventUnload).to.be.true
        });
      })
    })

    describe('with data attributes', function() {
      beforeEach(async function() {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`) 
        await createComponent(form, {
          'data-assistive-text': 'assistive text',
          'data-saved-label': 'all good',
          'data-unsaved-label': 'click me',
          'data-saving-label': 'working on it'
        });
        ({saveButton, form, input} = getElements());
      });

      describe('text', function() {
        it('should have labels from the data attributes', function() {
          expect(saveButton.text).to.deep.equal({
            saved: 'all good',
            unsaved: 'click me',
            saving: 'working on it'
          })
        })
      })
    })

  })
})

