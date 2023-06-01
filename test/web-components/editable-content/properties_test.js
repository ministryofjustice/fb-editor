require('../../setup');
const {
  createComponent,
  createTemplate,
  getElements,
  cleanBody 
} = require('./helpers')

const { EditableContent } = require( '../../../app/javascript/src/web-components/editable-content')
const ID = 'editable-content-component-properties'

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

  describe('Properties', function() {

    describe('When empty', function() {

      beforeEach( async function() {
        initialHTML = ``
        initialMarkdown = ''
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
      })

      describe('content', function() {
        it('should return empty', function() {
          expect(component.customElement.content).to.eq('')
        })
      })

      describe('isComponent', function() {
        it('should return false', function(){
          expect(component.customElement.isComponent).to.be.false
        })
      })
    })

    describe('When has content', function() {
      beforeEach( async function() {
        initialHTML = `<p>this is content</p>`
        initialMarkdown = 'this is content'
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
      })

      describe('content', function() {
        it('should return the content', function() {
          expect(component.customElement.content).to.eq(initialMarkdown)
        })
      })

      describe('isComponent', function() {
        it('should return false', function(){
          expect(component.customElement.isComponent).to.be.false
        })
      })
    })

    describe('When has component json', function() {
      beforeEach( async function() {
        initialHTML = `<p>this is content</p>`
        initialMarkdown = 'this is content'
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML, '{}');
        await createComponent('editable-content', html)
        component = getElements();
      })

      describe('content', function() {
        it('should return the json as a string', function() {
          expect(component.customElement.content).to.eq(`{"content":"${initialMarkdown}"}`)
        })
      })

      describe('isComponent', function() {
        it('should return false', function(){
          expect(component.customElement.isComponent).to.be.true
        })
      })
    })

  })
})

