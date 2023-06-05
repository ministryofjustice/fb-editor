require('../../setup');
const {
  createComponent,
  createTemplate,
  getElements,
  cleanBody 
} = require('./helpers')

const { EditableContent } = require( '../../../app/javascript/src/web-components/editable-content')
const ID = 'editable-content-component-events'

describe('<editable-content>', function() {
  const defaultContent = '[Optional content]'

  before(function() {
    if(!window.customElements.get('editable-content')) {
      window.customElements.define('editable-content', EditableContent)
    }
  })

  afterEach(function() {
    console.log('cleaning')
    cleanBody()
  })

  describe('Methods', function() {
    describe('Save', function() {
      beforeEach( async function() {
        initialHTML = `<p>this is content</p>`
        initialMarkdown = 'this is content'
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('button')
        form = document.querySelector('form')
      })

      it('creates input in form', function() {
        component.customElement.submissionForm = form;
        component.customElement.save()

        const hiddenInput = form.querySelector(`input[name="${ID}"]`)
        expect(hiddenInput).to.exist
        expect(hiddenInput).to.have.value('this is content')
      })

      it('updates input in form', function() {
        component.customElement.submissionForm = form;
        button.insertAdjacentHTML('beforebegin', `<input type="hidden" name="${ID}" value="Old content" />`)

        component.input.value = 'My new content'
        component.customElement.save()

        const hiddenInput = form.querySelector(`input[name="${ID}"]`)
        expect(hiddenInput).to.have.value('My new content')
      })
    })

    describe('Destroy', function() {
      beforeEach( async function() {
        initialHTML = `<p>this is content</p>`
        initialMarkdown = 'this is content'
        const config = { _uuid: '1234567890' }
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML, encodeURIComponent(JSON.stringify(config)) );
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('button')
        form = document.querySelector('form')
      })

      describe('When form input is present', function() {
        it('removes form input', function(){
          component.customElement.submissionForm = form;
          component.customElement.save()

          let hiddenInput = form.querySelector(`input[name="${ID}"]`)
          expect(hiddenInput).to.exist
          
          component.customElement.destroy();
          hiddenInput = form.querySelector(`input[name="${ID}"]`)
          expect(hiddenInput).not.to.exist
        })

        it('adds delete component input', function(){
          component.customElement.submissionForm = form;

          component.customElement.destroy();

          const deleteInput = form.querySelector(`input[name="delete_components[]"]`)
          expect(deleteInput).to.exist
          expect(deleteInput).to.have.value('1234567890')
        })

      })

      describe('When form input is not present', function() {
        it('adds delete component input', function(){
          component.customElement.submissionForm = form;

          component.customElement.destroy();
          const deleteInput = form.querySelector(`input[name="delete_components[]"]`)

          expect(deleteInput).to.exist
          expect(deleteInput).to.have.value('1234567890')
        })
      })

    })
  })
})
