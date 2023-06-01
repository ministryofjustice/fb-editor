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

  describe('Syntax parsing', function() {

    describe('Headings', function(){
      it('renders headings', async function() {
        initialMarkdown = '# Heading 1\r\n## Heading 2\r\n### Heading 3\r\n#### Heading 4'
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<h1 class="govuk-heading-l" id="heading-1">Heading 1</h1><h2 class="govuk-heading-m" id="heading-2">Heading 2</h2><h3 class="govuk-heading-s" id="heading-3">Heading 3</h3><h4 class="govuk-heading-s" id="heading-4">Heading 4</h4>`)
      })
    })

    describe('Links', function(){
      it('renders standard links', async function() {
        initialMarkdown = '[Link](http://example.com)'
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<p class="govuk-body"><a class="govuk-link" href="http://example.com">Link</a></p>`)
      })

      it('renders email links', async function() {
        initialMarkdown = '<email@address.com>'
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<p class="govuk-body"><a class="govuk-link" href="mailto:email@address.com">email@address.com</a></p>`)
      })
    })

    describe('Lists', function(){
      it('renders unordered lists', async function() {
        initialMarkdown = '- item 1\r\n- item 2\r\n- item 3'
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<ul class="govuk-list govuk-list--bullet"><li>item 1</li>
<li>item 2</li>
<li>item 3</li>
</ul>`)
      })

      it('renders nested unordered lists', async function() {
        initialMarkdown = '- item 1\r\n- item 2\r\n    - item 2a\r\n    - item 2b\r\n- item 3'
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<ul class="govuk-list govuk-list--bullet"><li>item 1</li>
<li>item 2<ul class="govuk-list govuk-list--bullet"><li>item 2a</li>
<li>item 2b</li>
</ul>
</li>
<li>item 3</li>
</ul>`)
      }) 

      it('renders ordered lists', async function() {
        initialMarkdown = '1. item 1\r\n2. item 2\r\n3. item 3'
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<ol class="govuk-list govuk-list--number"><li>item 1</li>
<li>item 2</li>
<li>item 3</li>
</ol>`)
      })

      it('renders nested ordered lists', async function() {
        initialMarkdown = '1. item 1\r\n2. item 2\r\n    1. item 2.1\r\n    2. item 2.2\r\n3. item 3'
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<ol class="govuk-list govuk-list--number"><li>item 1</li>
<li>item 2<ol class="govuk-list govuk-list--number"><li>item 2.1</li>
<li>item 2.2</li>
</ol>
</li>
<li>item 3</li>
</ol>`)
      })
    })

    describe('Tables', function() {
      it('renders tables', async function() {
        initialMarkdown = `| Header 1 | Header 2 |
| -------- | -------- |
| Cell | Cell |
| Cell | Cell |`
        const html = createTemplate(ID, defaultContent, initialMarkdown);
        await createComponent('editable-content', html)
        component = getElements();
        button = document.querySelector('form > button');

        component.root.focus();
        button.focus();

        expect(component.output).to.contain.html(`<table class="govuk-table">
<thead class="govuk-table__head">
<tr class="govuk-table__row">
<th class="govuk-table__header">Header 1</th>
<th class="govuk-table__header">Header 2</th>
</tr>
</thead>
<tbody class="govuk-table__body"><tr class="govuk-table__row">
<td class="govuk-table__cell">Cell</td>
<td class="govuk-table__cell">Cell</td>
</tr>
<tr class="govuk-table__row">
<td class="govuk-table__cell">Cell</td>
<td class="govuk-table__cell">Cell</td>
</tr>
</tbody>
</table>`)
      })
    })

    describe('Soft linebreaks', function() {
      it('renders double spaces as linebreaks', async function() {
          initialMarkdown = `line 1  
line 2`
          const html = createTemplate(ID, defaultContent, initialMarkdown);
          await createComponent('editable-content', html)
          component = getElements();
          button = document.querySelector('form > button');

          component.root.focus();
          button.focus();

        expect(component.output).to.contain.html(`<p class="govuk-body">line 1<br>line 2</p>`)
      })
    })


    describe('Govspeak', function() {
      describe('call to action', function() {
        it('renders govspeak call to action block', async function() {
          initialMarkdown = `$CTA
Call to action
$CTA`
          const html = createTemplate(ID, defaultContent, initialMarkdown);
          await createComponent('editable-content', html)
          component = getElements();
          button = document.querySelector('form > button');

          component.root.focus();
          button.focus();

          expect(component.output).to.contain.html(`<div class="govspeak-call-to-action">
      <p class="govuk-body">Call to action</p>

    </div>`)
        })
      })
    })

  })
})
