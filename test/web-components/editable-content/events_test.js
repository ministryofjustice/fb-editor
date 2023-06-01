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

  describe('Events', function() {
    let saveRequired;
    let button;
    const saveHandler = () => {
      saveRequired = true;
    }

    beforeEach(function() {
      saveRequired = false;
      document.addEventListener('SaveRequired', saveHandler);      
    })

    afterEach(function() {
      saveRequired = false;
      document.removeEventListener('SaveRequired', saveHandler);
    })

    describe('When empty', function() {
      beforeEach( async function() {
        initialHTML = ``
        initialMarkdown = ''
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('button')
      })

      it('should emit saveRequired when content is blank', function(){
        component.root.focus()
        button.focus()

        expect(saveRequired).to.be.true
      })
      
      it('should emit saveRequired event if content is changed', function() {
        component.root.focus()
        component.input.value = 'Updated content'
        button.focus()

        expect(saveRequired).to.be.true
      })
    })

    describe('When has content', function() {
      beforeEach( async function() {
        initialHTML = `<p>this is content</p>`
        initialMarkdown = 'this is content'
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('button')
      })

      it('should not emit saveRequired when content isn\'t changed', function(){
        component.root.focus()
        button.focus()

        expect(saveRequired).to.be.false
      })

      it('should emit saveRequired event if content is changed', function() {
        component.root.focus()
        component.input.value = 'Updated content'
        button.focus()

        expect(saveRequired).to.be.true
      })
    })
  })
})

