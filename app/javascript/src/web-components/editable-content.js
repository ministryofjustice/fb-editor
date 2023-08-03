const marked = require('marked')
const govspeak = require('@x-govuk/marked-govspeak')
const GovukHTMLRenderer = require('govuk-markdown')
const DOMPurify = require('dompurify')

DOMPurify.addHook("afterSanitizeAttributes", function (node, data, config) {
  if (node.nodeName === "A" && node.classList.contains("govuk-button")) {
    // Replace it with a link
    // node.classList.remove("gem-c-button", "govuk-button", "govuk-button--start");
    // node.classList.add('govuk-link')

    // Or remove it (and its wrapper <p>)
    node.parentNode.remove();
  }
});

class EditableContent extends HTMLElement {
  constructor() {
    super() 

    const self = this

    this.state = new Proxy(
      {
        mode: 'read',
      },
      {
        set(state, key, value) {
          const oldValue = state[key];

          state[key] = value;
          if (oldValue !== value) {
            self.processStateChange();
          }
          return state;
        }
      }
    )

    const allowedGovspeakComponents = [
      'govspeak-warning-callout',
      'govspeak-information-callout',
      'govspeak-address',
      'govspeak-call-to-action',
      'govspeak-contact',
      'govspeak-button' // We need to allow it, for it to gain the govuk-button classes. Then DOMPurify will remove it
    ]

    marked.setOptions({
      renderer: new GovukHTMLRenderer(),
      headingsStartWith: 'xl',
      // govspeakGemCompatibility: true
    })

    marked.use({ 
      extensions: govspeak.filter((component) => allowedGovspeakComponents.includes(component.name) )
    })
  }

  connectedCallback() {
    // connectedCallback is fired as soon as the opening element is parsed
    // setTimeount allows the child elements to be parsed before we try to read
    // the initialMarkup
    setTimeout(() => {
      this.initialMarkup = this.innerHTML;
      this.initialContent = this.getAttribute('content')?.replace(/\\r\\n?|\\n/g, '\n') || '';
      this.defaultContent = this.getAttribute('default-content') || '';
      this.config = (this.dataset.config ? JSON.parse(decodeURIComponent(this.dataset.config)) : undefined);
      this.render();
    })
  }

  // Markdown content that will be saved
  // If content area is part of page components we need to return compontn json
  // as a string otherwise we return the content string
  get content() {
    if(this.isComponent) {
      this.config.content = this.input.value;
      return JSON.stringify(this.config);
    } else {
      return this.input.value == this.defaultContent ? '' : this.input.value;
    }
  }

  get html() {
    const content = this.input.value || this.defaultContent
    const unsafeHTML = marked.parse(content);
    return this.sanitize(unsafeHTML)
  }

  // Is the content area part of the page components 
  get isComponent() {
    return !!this.config;
  }

  get $node() {
    return $(this);
  }

  // The form containing the element that will be updated on save
  set form(element) {
    this.submissionForm = element;
  }

  render() {
    const initialContent = this.initialContent || this.defaultContent;
    const initialMarkup = (this.initialMarkup.trim() != '' ? this.sanitize(this.initialMarkup) : this.defaultContent);
    this.innerHTML = `
    <div class="editable-content" data-element="editable-content-root">
      <elastic-textarea>
        <textarea class="" data-element="editable-content-input" rows="8" hidden>${initialContent}</textarea>
      </elastic-textarea>
      <div data-element="editable-content-output">${initialMarkup}</div>
    </div>`
    
    this.afterRender()
  }

  afterRender() {
    this.root = this.querySelector('[data-element="editable-content-root"]')
    this.input = this.querySelector('[data-element="editable-content-input"]')
    this.output = this.querySelector('[data-element="editable-content-output"]')

    if(this.input && this.output) {
      this.root.setAttribute('tabindex', '0');
      this.root.setAttribute('mode', this.state.mode)

      this.input.dataset.minRows = this.input.rows || 5;

      this.root.addEventListener('click', () => this.state.mode = 'edit' )
      this.root.addEventListener('focus', () => this.state.mode = 'edit' )
      // this.input.addEventListener('blur', () => this.state.mode = 'read' )
      this.addEventListener('focusout', (event) => {
        if(this.contains(event.relatedTarget)) return
        this.state.mode = 'read'
      })

      return
    }
    
    // If we don't have input and output elements, bail and just restore the
    // initial markup
    this.innerHTML = this.initialMarkup;
  }

  processStateChange() {
    this.root.setAttribute('mode', this.state.mode)

    switch(this.state.mode) {
      case 'edit':
        this._contentBeforeEditing = this.input.value.trim();
        this.show(this.input)
        this.hide(this.output)
        this.classList.add('active')
        this.input.focus({ preventScroll: true });

        if(this.valueIsDefault()) this.input.value = '';
        // Move cursor to end of content 
        this.input.selectionStart = this.input.value.length;
        break;
      case 'read':
      case 'initial':
        if(this.valueIsDefault()) this.input.value = '';
        this.updateOutput();
        
        this.hide(this.input);
        this.show(this.output);
        this.classList.remove('active')

        if(this.valueHasChanged()) {
          this.save();
          document.dispatchEvent( 
            new CustomEvent( 
              'SaveRequired', 
              { 
                bubbles: true, 
              }
            )
          );
        } 
        break;
    }
  }

  hide(element) {
    element.setAttribute('hidden', '');
  }

  show(element) {
    element.removeAttribute('hidden');
  }

  updateOutput(){
    this.output.innerHTML = this.html   
  }

  valueIsDefault() {
    return this.input.value == this.defaultContent;
  }

  valueHasChanged() {
    return this.input.value.trim() !== this._contentBeforeEditing 
  }

  save() {
    if(!this.submissionForm) return
    const hiddenInput = this.submissionForm.querySelector(`input[name="${this.id}"]`);
    if(hiddenInput) {
      hiddenInput.value = this.content;
    } else {
      const button = this.submissionForm.querySelector('button[type="submit"], input[type="submit"]');
      const newInputHTML = `<input type="hidden" name="${this.id}" value="${this.content}" />`
      button.insertAdjacentHTML('beforebegin', newInputHTML);
    }
  }

  destroy() {
    if(!this.submissionForm) return
    const hiddenInput = this.submissionForm.querySelector(`input[name="${this.id}"]`);
    const button = this.submissionForm.querySelector('button[type="submit"], input[type="submit"]');

    if(hiddenInput) {
      hiddenInput.remove()
    }
    
    const deleteInputHTML = `<input type="hidden" name="delete_components[]" value="${this.config._uuid}" />`
    button.insertAdjacentHTML('beforebegin', deleteInputHTML);
    this.remove()
  }

  sanitize(unsafeHTML) {
    return DOMPurify.sanitize(unsafeHTML, {
        USE_PROFILES: {html: true}, 
        FORBID_TAGS: ['style', 'button']
    })  
  }
}

module.exports = { EditableContent }
