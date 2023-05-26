import 'jsdom-global/register.js'
import 'chai/register-expect.js';
import chai from 'chai'
const expect  = chai.expect 
import chaiDom from 'chai-dom'
chai.use(chaiDom)
import EditableContent from '../../../app/javascript/src/web-components/editable-content.mjs'
//

describe('EditableContent', function() {
  const id = 'editable-content-component'
  const initialHTML = `<h1>this is content</h1>`
  const initialMarkdown = '# this is content'

  before(function() {
    // We can only register the element once
    window.customElements.define('editable-content', EditableContent)    
  })

  beforeEach(function() {
    var html = `<form id="${id}-form">
        <button type=submit>Save</button>
      </form>
      <editable-content id="${id}" default-content="${initialMarkdown}">${initialHTML}</editable-content>`;

    return window.customElements.whenDefined('editable-content').then(() => {
      document.body.insertAdjacentHTML('afterbegin', html);
      return new Promise(resolve => setTimeout(resolve, 0));
    })    
  })

  afterEach(function() {
    document.body.innerHTML = '' 
  })

  it('should create an instance of EditableContent', function() {
    const component = document.querySelector('editable-content')
    expect(component).to.exist
    expect(component).to.be.instanceOf(EditableContent)
  })

  it('should enhance the markup', function() {
    const root = document.querySelector('[data-element="editable-content-root"]')
    const input = document.querySelector('[data-element="editable-content-input"]')
    const output = document.querySelector('[data-element="editable-content-output"]')
    
    expect(root).to.exist
    expect(input).to.exist
    expect(output).to.exist
  })

  it('should set the initial visibility', function() {
    const input = document.querySelector('[data-element="editable-content-input"]')
    const output = document.querySelector('[data-element="editable-content-output"]')

    expect(output).to.be.displayed
    expect(input).not.to.be.displayed
  })

  it('should insert initial content into output element', function() {
    const output = document.querySelector('[data-element="editable-content-output"]')

    expect(output).to.have.html(initialHTML)
  });

  it('should insert initial markdown into input element', function() {
    const input = document.querySelector('[data-element="editable-content-input"]')

    expect(input).to.have.value(initialMarkdown)
  });

  it('should show the input on click', function() {
    const input = document.querySelector('[data-element="editable-content-input"]')
    const output = document.querySelector('[data-element="editable-content-output"]')

    output.click()
    
    expect(output).not.to.be.displayed
    expect(input).to.be.displayed
  })

  it('should show the input on focus and hide again on blur', function() {
    const root = document.querySelector('[data-element="editable-content-root"]')
    const input = document.querySelector('[data-element="editable-content-input"]')
    const output = document.querySelector('[data-element="editable-content-output"]')
    const button = document.querySelector('button')

    root.focus()
    
    expect(output).not.to.be.displayed
    expect(input).to.be.displayed
    
    button.focus()

    expect(output).to.be.displayed
    expect(input).not.to.be.displayed
  })



})
