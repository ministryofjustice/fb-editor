
async function createComponent(element, html) {
  await window.customElements.whenDefined('editable-content')
  document.body.insertAdjacentHTML('beforeend', html);
  await new Promise(resolve => setTimeout(resolve, 0));
}

function createTemplate(id, defaultContent='', markdown='', html='', json='') {
  return `
  <form id="${id}-form">
    <button type=submit>Save</button>
  </form>
  <editable-content id="${id}" default-content="${defaultContent}" content="${markdown}" data-json="${json}" >
    ${html}
  </editable-content>`
}

function getElements() {
  return {
    customElement: document.querySelector('editable-content'),
    root: document.querySelector('[data-element="editable-content-root"]'),
    input: document.querySelector('[data-element="editable-content-input"]'),
    output: document.querySelector('[data-element="editable-content-output"]')
  }
}

function cleanBody() {
  document.body.innerHTML = ''
}

module.exports = {
  createComponent,
  createTemplate,
  getElements,
  cleanBody
}
