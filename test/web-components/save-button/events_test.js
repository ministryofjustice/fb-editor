require('../../setup');
const {
  createComponent,
  createTemplate,
  getElements,
  cleanBody 
} = require('./helpers')

const { SaveButton } = require( '../../../app/javascript/src/web-components/save-button')
const ID = 'save-button-component-events-form'

describe('save-button', function() {
  let form, saveButton, input, description;
  const sandbox = sinon.createSandbox();
    
  before(function() {
    if(!window.customElements.get('save-button')) {
      window.customElements.define('save-button', SaveButton, {extends: 'button'})
    }
  })

  afterEach(function() {
    sandbox.restore();
    saveButton = form = input = description = undefined
    cleanBody()
  })
  
  describe('Events', function(){
    
    describe('click', function() {
      
      describe('when save not required', function() {
        beforeEach(async function() {
          const html = createTemplate(ID);
          form = document.querySelector(`#${ID}`) 
          await createComponent(form);
          ({saveButton, form, input, description} = getElements());
        });
        
        it('should not submit the form', function() {
          const listener = sandbox.spy()
          form.addEventListener('submit', listener)

          saveButton.click()

          expect(listener).to.not.have.been.called
        })
      })

      describe('when save required', function() {
        beforeEach(async function() {
          const html = createTemplate(ID);
          form = document.querySelector(`#${ID}`) 
          await createComponent(form, {
            'save-required': 'true'
          });
          ({saveButton, form, input, description} = getElements());
        });
        
        it('should submit the form', function() {
          const listener = sandbox.spy()
          form.addEventListener('submit', listener)
          form.addEventListener('submit', (e) => e.preventDefault()) //dont actually try and submit

          saveButton.click()

          expect(listener).to.have.been.calledOnce
        })
      })

    })

    describe('submit', function() {

      describe('when save not required', function() {
        beforeEach(async function() {
          const html = createTemplate(ID);
          form = document.querySelector(`#${ID}`) 
          await createComponent(form);
          ({saveButton, form, input, description} = getElements());
        });
        
        it('should not submit the form', function() {
          const listener = sandbox.spy()
          form.addEventListener('submit', listener)
          form.addEventListener('submit', (e) => e.preventDefault()) //dont actually try and submit

          const event = new Event('submit', {
            bubbles: true,
            cancelable: true
          });
          form.dispatchEvent(event);

          expect(listener).to.not.have.been.called
        })
      })

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

        it('should submit the form', function() {
          const listener = sandbox.spy()

          form.addEventListener('submit', listener)
          form.addEventListener('submit', (e) => e.preventDefault()) //dont actually try and submit

          const event = new Event('submit', {
            bubbles: true,
            cancelable: true
          });
          form.dispatchEvent(event);

          expect(listener).to.have.been.calledOnce
        })

        it('should remove the beforeunload listener', function() {
          const removeEventListenerSpy = sandbox.spy(window, 'removeEventListener')

          form.addEventListener('submit', (e) => e.preventDefault()) //dont actually try and submit

          const event = new Event('submit', {
            bubbles: true,
            cancelable: true
          });
          form.dispatchEvent(event);

          expect(removeEventListenerSpy).to.have.been.calledOnce
        })
      })
    })

    describe('input', function() {
      beforeEach(async function() {
        const html = createTemplate(ID);
        form = document.querySelector(`#${ID}`) 
        await createComponent(form);
        ({saveButton, form, input, description} = getElements());
      });

      it('should set saveRequired on input', function() {
        expect(saveButton.saveRequired).to.be.false

        const event = new Event('input', {
          bubbles: true,
          cancelable: true
        });
        input.dispatchEvent(event);

        expect(saveButton.saveRequired).to.be.true
      })

    })
  })
})
