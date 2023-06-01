
require('../../setup');
const {
  createComponent,
  createTemplate,
  getElements,
  cleanBody 
} = require('./helpers')

const { EditableContent } = require( '../../../app/javascript/src/web-components/editable-content')
const ID = 'editable-content-component-behaviours'

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

  describe('Behaviours', function(){
    describe('core', function() {
      beforeEach( async function() {
        initialHTML = ``
        initialMarkdown = ''
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
      })

      it('should create an instance of EditableContent', function() {
        expect(component.customElement).to.exist
        expect(component.customElement).to.be.instanceOf(EditableContent)
      })

      it('should enhance the markup', function() {
        expect(component.root).to.exist
        expect(component.input).to.exist
        expect(component.output).to.exist
      })

      it('should set the initial visibility', function() {
        expect(component.output).to.be.displayed
        expect(component.input).not.to.be.displayed
      })

      it('should show the input on click', function() {
        component.output.click()

        expect(component.output).not.to.be.displayed
        expect(component.input).to.be.displayed
        expect(component.input).to.have.focus
      })

      it('should show the input on focus and hide again on blur', function() {
        const button = document.querySelector('button')

        component.root.focus()

        expect(component.output).not.to.be.displayed
        expect(component.input).to.be.displayed
        expect(component.input).to.have.focus

        button.focus()

        expect(component.output).to.be.displayed
        expect(component.input).not.to.be.displayed
        expect(component.input).not.to.have.focus
      })

      it('should be focusable', function() {
        expect(component.root).to.have.attr('tabindex', '0')
      });
    });

    describe('When empty', function() {
      beforeEach( async function() {
        initialHTML = ``
        initialMarkdown = ''
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
      })

      it('should insert initial html into output element', function() {
        expect(component.output).to.include.html(initialHTML)
      });

      it('should insert default content into input element', function() {
        expect(component.input).to.have.value(defaultContent)
      });

      it('should know the value is default', function() {
        expect(component.customElement.valueIsDefault()).to.be.true
      });

      it('should remove the default content on focus', function() {
        component.root.focus()

        expect(component.input.value).to.eq('')
      })
    })

    describe('When has content', function() {
      beforeEach( async function() {
        initialHTML = `<p>This is content</p>`
        initialMarkdown = 'This is content'
        const html = createTemplate(ID, defaultContent, initialMarkdown, initialHTML);
        await createComponent('editable-content', html)
        component = getElements();
      })

      it('should insert initial html into output element', function() {
        console.log(document.body.innerHTML)
        expect(component.output).to.include.html(initialHTML)
      });

      it('should insert content into input element', function() {
        expect(component.input).to.have.value(initialMarkdown)
      });
  
      it('should update the output html on blur', function() {
        const button = document.querySelector('button')

        component.root.focus()

        component.input.value = '# Heading 1\r\n\r\nThis is a paragraph'

        button.focus()

        expect(component.output).to.have.html(`<h1 class="govuk-heading-l" id="heading-1">Heading 1</h1><p class="govuk-body">This is a paragraph</p>
`)
      })
    })
  })
})


