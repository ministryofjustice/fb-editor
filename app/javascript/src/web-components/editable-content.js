const marked = require('marked')
const govspeak = require('@x-govuk/marked-govspeak')
const GovukHTMLRenderer = require('govuk-markdown')
const DOMPurify = require('dompurify')

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

    this.markdownFilters = {
      convertButtonsToLinks: (markdown) => {
        markdown = markdown.replace(/{button\s?(?:start)?}/gi, '')
        markdown = markdown.replace(/{\/button\s?}/gi, '')

        return markdown
      },
    }

    const allowedGovspeakComponents = [
      'govspeak-warning-callout',
      'govspeak-information-callout',
      'govspeak-address',
      'govspeak-call-to-action',
      'govspeak-contact',
    ]

    const preprocess = (markdown) => {
      markdown = this.filterMarkdown(markdown)
      return markdown
    }

    marked.setOptions({
      renderer: new GovukHTMLRenderer(),
      headingsStartWith: 'xl',
      govspeakGemCompatibility: true
    })

    marked.use({ 
      extensions: govspeak.filter((component) => allowedGovspeakComponents.includes(component.name) ),
      hooks: { preprocess }
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
      this.config = (this.dataset.config ? JSON.parse(this.dataset.config) : undefined);
      this.render();
    })
  }

  // Markdown content that will be saved
  // If content area is part of page components we need to return compontn json
  // as a string otherwise we return the content string
  get content() {
    if(this.isComponent) {
      this.config.content = this.value;
      return JSON.stringify(this.config);
    } else {
      return this.value == this.defaultContent ? '' : this.value;
    }
  }

  get html() {
    const content = this.value || this.defaultContent
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
  
  // returns the markdown content of the input after filtering it through any
  // configured filters
  get value() {
    let val = this.input.value

    for( const [key, filterFunction] of Object.entries(this.markdownFilters)) {
      val = filterFunction(val)
    }

    return val
  }

  set value(value) {
    this.input.value = value
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

        if(this.valueIsDefault()) this.value = '';
        // Move cursor to end of content 
        this.input.selectionStart = this.value.length;
        break;
      case 'read':
      case 'initial':
        if(this.valueIsDefault()) this.value = '';
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
    return this.value == this.defaultContent;
  }

  valueHasChanged() {
    return this.value.trim() !== this._contentBeforeEditing 
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

  // Run the markdown through all configured filter functions
  // called by marked in the preprocess hook 
  // called in the value() getter
  filterMarkdown(markdown) {
    for( const [key, filterFunction] of Object.entries(this.markdownFilters)) {
      markdown = filterFunction(markdown)
    }
    return markdown
  }

  sanitize(unsafeHTML) {
    return DOMPurify.sanitize(unsafeHTML, {
        USE_PROFILES: {html: true}, 
        FORBID_TAGS: ['style', 'button']
    })  
  }
}

module.exports = { EditableContent }
