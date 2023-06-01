// require('jsdom-global')()
// const chai = require('chai')
// const chaiDom = require('chai-dom')
// const expect  = chai.expect 
// chai.use(chaiDom)
// const { EditableContent } = require( '../../../app/javascript/src/web-components/editable-content')

// async function createComponent(element, html) {
//   await window.customElements.whenDefined('editable-content')
//   document.body.insertAdjacentHTML('beforeend', html);
//   await new Promise(resolve => setTimeout(resolve, 0));
// }

// function getElements() {
//   return {
//     element: document.querySelector('editable-content'),
//     root: document.querySelector('[data-element="editable-content-root"]'),
//     input: document.querySelector('[data-element="editable-content-input"]'),
//     output: document.querySelector('[data-element="editable-content-output"]')
//   }
// }

// describe('EditableContent', function() {
//   const id = 'editable-content-component'

//   before(function() {
//     // We can only register the element once
//     window.customElements.define('editable-content', EditableContent)
//   })

//   describe('When empty', function() {
//     const defaultContent = '[Optional content]'
//     const initialHTML = ``
//     const initialMarkdown = ''
//     let component;

//     beforeEach( async function() {
//       var html = `<form id="${id}-form">
//       <button type=submit>Save</button>
//     </form>
//     <editable-content id="${id}" 
//                       default-content="${defaultContent}"
//                       content="${initialMarkdown}">
//       ${initialHTML}
//     </editable-content>`;

//       await createComponent('editable-content', html)
//       component = getElements();
//     })

//     afterEach(function() {
//       document.body.innerHTML = '' 
//     })

//     it('should create an instance of EditableContent', function() {
//       expect(component.element).to.exist
//       expect(component.element).to.be.instanceOf(EditableContent)
//     })

//     it('should enhance the markup', function() {
//       expect(component.root).to.exist
//       expect(component.input).to.exist
//       expect(component.output).to.exist
//     })

//     it('should set the initial visibility', function() {
//       expect(component.output).to.be.displayed
//       expect(component.input).not.to.be.displayed
//     })

//     it('should insert initial html into output element', function() {
//       expect(component.output).to.include.html(initialHTML)
//     });

//     it('should insert default content into input element', function() {
//       expect(component.input).to.have.value(defaultContent)
//     });

//     it('should show the input on click', function() {
//       component.output.click()

//       expect(component.output).not.to.be.displayed
//       expect(component.input).to.be.displayed
//       expect(component.input).to.have.focus
//     })

//     it('should show the input on focus and hide again on blur', function() {
//       const button = document.querySelector('button')

//       component.root.focus()

//       expect(component.output).not.to.be.displayed
//       expect(component.input).to.be.displayed
//       expect(component.input).to.have.focus

//       button.focus()

//       expect(component.output).to.be.displayed
//       expect(component.input).not.to.be.displayed
//       expect(component.input).not.to.have.focus
//     })

//     it('should be focusable', function() {
//       expect(component.root).to.have.attr('tabindex', '0')
//     });

//     it('should know the value is default', function() {
//         expect(component.element.valueIsDefault()).to.be.true
//     });

//     it('should remove the default content on focus', function() {
//       component.root.focus()

//       expect(component.input.value).to.eq('')
//     })

//     // should emit save on content change
//     describe('Events', function() {
//       let saveRequired = false;

//       const saveHandler = () => {
//             saveRequired = true;
//       }
//       beforeEach(function() {
//         document.addEventListener('SaveRequired', saveHandler);      
//       })

//       afterEach(function() {
//         document.removeEventListener('SaveRequired', saveHandler);
//       })

//       it('should emit saveRequired event when content is left as default', function() {
//         const button = document.querySelector('button')

//         component.root.focus()
//         button.focus()

//         expect(saveRequired).to.be.false
//       })

//       it('should emit saveRequired event if content is changed', function() {
//         const button = document.querySelector('button')

//         component.root.focus()
//         component.input.value = 'Updated content'
//         button.focus()

//         expect(component.input.value).to.eq('Updated content')
//         expect(component.output).to.include.html('<p>Updated content</p>')
//         expect(saveRequired).to.be.true
//       })
//     })

//   });

//   describe('With content', function() {
//     const defaultContent = '[Optional content]'
//     const initialHTML = `<p>This is content</p>`
//     const initialMarkdown = 'This is content'
//     let component;

//     beforeEach( async function() {
//       var html = `<form id="${id}-form">
//       <button type=submit>Save</button>
//     </form>
//     <editable-content id="${id}" 
//                       default-content="${defaultContent}"
//                       content="${initialMarkdown}">
//       ${initialHTML}
//     </editable-content>`;

//       await createComponent('editable-content', html)
//       component = getElements();
//     })

//     afterEach(function() {
//       document.body.innerHTML = '' 
//     })


//     it('should insert initial html into output element', function() {
//       expect(component.output).to.include.html(initialHTML)
//     });

//     it('should insert content into input element', function() {
//       expect(component.input).to.have.value(initialMarkdown)
//     });

//     it('should update the output html', function() {
//         const button = document.querySelector('button')

//         component.root.focus()

//         component.input.value = '# Heading 1\r\n\r\nThis is a paragraph'

//         button.focus()

//         expect(component.output).to.have.html(`<h1 id="heading-1">Heading 1</h1>
// <p>This is a paragraph</p>
// `)
//     })

//     it('should support govspeak $cta tags', function() {
//         const button = document.querySelector('button')

//         component.root.focus()

//         component.input.value = `$CTA
// This is a call to action
// $CTA`

//         button.focus()

//         expect(component.output).to.have.html(`<div class="govspeak-call-to-action">
//       <p>This is a call to action</p>

//     </div>`)
//     })

//     describe('Events', function() {
//       let saveRequired = false;

//       const saveHandler = () => {
//             saveRequired = true;
//       }

//       beforeEach(function() {
//         document.addEventListener('SaveRequired', saveHandler);      
//       })

//       afterEach(function() {
//         document.removeEventListener('SaveRequired', saveHandler);
//       })

//       it('should not emit saveRequired event if content does not change', function() {
//         const button = document.querySelector('button')

//         component.root.focus()
//         button.focus()

//         expect(saveRequired).to.be.false
//       })

//       it('should emit saveRequired event if content is changed', function() {
//         const button = document.querySelector('button')

//         component.root.focus()
//         component.input.value = 'Updated content'
//         button.focus()

//         expect(component.input.value).to.eq('Updated content')
//         expect(component.output).to.include.html('<p>Updated content</p>')
//         expect(saveRequired).to.be.true
//       })
//     })
//   });
// })
