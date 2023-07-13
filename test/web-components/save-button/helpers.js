async function createComponent(form, attributes={}) {
  await window.customElements.whenDefined('save-button')

  let button = document.createElement('button', {is: 'save-button'})
  
  for(const [attr, value] of Object.entries(attributes)) {
    button.setAttribute(attr, value);
  };

  button.innerText = 'Default Label'

  form.append(button)

  await new Promise(resolve => setTimeout(resolve, 0));
}

function createTemplate(id) {
  const html = `
  <form id="${id}">
    <input name="text-input" type="text" value="" />
  </form>`;

  document.body.insertAdjacentHTML('beforeend', html)
}

function getElements() {
  return {
    saveButton: document.querySelector('button'),
    form: document.querySelector('form'),
    input: document.querySelector('input[name="text-input"]'),
    description: document.querySelector('span')
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
