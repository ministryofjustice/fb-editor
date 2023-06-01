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
  })
})
