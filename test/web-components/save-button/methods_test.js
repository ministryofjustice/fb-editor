require('../../setup');
const {
  createComponent,
  createTemplate,
  getElements,
  cleanBody 
} = require('./helpers')

const { SaveButton } = require( '../../../app/javascript/src/web-components/save-button')
const ID = 'save-button-component-methods-form'

describe('save-button', function() {
  let form, saveButton, input, description;

  before(function() {
    if(!window.customElements.get('save-button')) {
      window.customElements.define('save-button', SaveButton, {extends: 'button'})
    }
  })

  afterEach(function() {
    saveButton = form = input = description = undefined
    cleanBody()
  })

  describe('Methods', function(){
    describe('setting save-required', function() {
      beforeEach(async function() {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`) 
        await createComponent(form);
        ({saveButton, form, input, description} = getElements());
      });

      it('sets attribute for empty string', function(){
        expect(saveButton.saveRequired).to.be.false

        saveButton.saveRequired = ''
        expect(saveButton.saveRequired).to.be.true;
        expect(saveButton).to.have.attribute('save-required','')
      })

      it('sets attribute for true', function(){
        expect(saveButton.saveRequired).to.be.false

        saveButton.saveRequired = true
        expect(saveButton.saveRequired).to.be.true;
        expect(saveButton).to.have.attribute('save-required','true')
      })

      it('sets attribute for "true"', function(){
        expect(saveButton.saveRequired).to.be.false

        saveButton.saveRequired = 'true'
        expect(saveButton.saveRequired).to.be.true;
        expect(saveButton).to.have.attribute('save-required','true')
      });
    });

    describe('removing save-required', function() {
      beforeEach(async function() {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`) 
        await createComponent(form, {
          'save-required': 'true'
        });
        ({saveButton, form, input, description} = getElements());
      });

      it('removes attribute for "false"', function(){
        expect(saveButton.saveRequired).to.be.true

        saveButton.saveRequired = 'false'
        expect(saveButton.saveRequired).to.be.false;
        expect(saveButton).to.not.have.attribute('save-required')
      })

      it('removes attribute for false', function(){
        expect(saveButton.saveRequired).to.be.true

        saveButton.saveRequired = false
        expect(saveButton.saveRequired).to.be.false;
        expect(saveButton).to.not.have.attribute('save-required')
      })

      it('removes attribute for any other value', function(){
        expect(saveButton.saveRequired).to.be.true

        saveButton.saveRequired = 'an incorrect value'
        expect(saveButton.saveRequired).to.be.false;
        expect(saveButton).to.not.have.attribute('save-required')
      });
    });

    describe('save()', function() {
      const sandbox = sinon.createSandbox();

      describe('when save required', function() {
        beforeEach(async function() {
          const html = createTemplate(ID);
          form = document.querySelector(`#${ID}`) 
          await createComponent(form, {
            'save-required': 'true',
            'prevent-unload': 'true'
          });
          ({saveButton, form, input, description} = getElements());
        });

        afterEach(function() {
          sandbox.restore();
        })

        it('submits the form', function() {
          const formSubmitSpy = sandbox.spy(form, 'submit')

          saveButton.save();

          expect(formSubmitSpy).to.have.been.calledOnce;
        })

        it('removes the beforeunload listener', function() {
          const removeEventListenerSpy = sandbox.spy(window, 'removeEventListener')

          saveButton.save()

          expect(removeEventListenerSpy).to.have.been.calledOnce;
        })

      })
    })
  })
})
