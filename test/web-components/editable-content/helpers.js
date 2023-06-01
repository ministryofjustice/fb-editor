async function createComponent(element, html) {
  await window.customElements.whenDefined('editable-content')
  document.body.insertAdjacentHTML('beforeend', html);
  await new Promise(resolve => setTimeout(resolve, 0));
}

function getElements() {
  return {
    element: document.querySelector('editable-content'),
    root: document.querySelector('[data-element="editable-content-root"]'),
    input: document.querySelector('[data-element="editable-content-input"]'),
    output: document.querySelector('[data-element="editable-content-output"]')
  }
}

module.exports = {
  createComponent,
  getElements
}
