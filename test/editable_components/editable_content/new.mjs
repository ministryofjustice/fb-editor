import 'jsdom-global/register.js'
// import jsdom from 'jsdom-global'
// import 'chai/register-assert.js';
import 'chai/register-expect.js';

// const chai = require("chai");
// const expect = chai.expect;
// const sinonChai = require("sinon-chai");
// // const jsdom = require("jsdom");
// // const jsdom= require('jsdom-global')()
//
import chai from 'chai'
const expect  = chai.expect 
import chaiDom from 'chai-dom'
chai.use(chaiDom)
import EditableContent from '../../../app/javascript/src/web-components/editable-content.mjs'

describe('EditableContent', function() {

  before(function() {
    const id='mycomponent';
    var html = `<form id="${id}-form">
      </form>
      <editable-content id="${id}"><h1>this is content</h1></editable-content>`;

    // jsdom(html)
    // const expect = chai.expect
  //   jsdom = require('jsdom-global')()
    window.customElements.define('editable-content', EditableContent)
    
    const el = document.createElement('editable-content');
    document.body.appendChild(el);
  })

  it('should create a component', function() {
    
    
    //assert.instanceOf(el, EditableContent)
    const ec = document.querySelector('editable-content')
    expect(ec).to.exist
    expect(ec).to.be.instanceOf(EditableContent)

    expect(document.querySelector('[data-element="editable-content-input]')).to.exist  
  })

})
