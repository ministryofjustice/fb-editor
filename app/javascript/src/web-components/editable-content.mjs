import {marked} from 'marked';
import govspeak from 'marked-govspeak'
import GovukHTMLRenderer from 'govuk-markdown'

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

    marked.use({ 
      renderer: GovukHTMLRenderer,
      extensions: govspeak 
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
      this.json = (this.dataset.json ? JSON.parse(this.dataset.json) : undefined);
      this.render();
    })
  }

  // Markdown content that will be saved
  // If content area is part of page components we need to return compontn json
  // as a string otherwise we return the content string
  get content() {
    if(this.isComponent) {
      this.json.content = this.input.value;
      console.log(this)
      return JSON.stringify(this.json);
    } else {
      return this.input.value == this.defaultContent ? '' : this.input.value;
    }
  }

  // Is the content area part of the page components 
  get isComponent() {
    return !!this.json;
  }

  // The form containing the element that will be updated on save
  set form(element) {
    this.submissionForm = element;
  }

  render() {
    const initialContent = this.initialContent || this.defaultContent;
    const initialMarkup = (this.initialMarkup.trim() != '' ? this.initialMarkup : this.defaultContent);
    this.innerHTML = `
    <div class="editable-content" data-element="editable-content-root">
      <textarea class="govuk-textarea" data-element="editable-content-input" rows="10" hidden>${initialContent}</textarea>
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

      this.input.dataset.minRows = this.input.rows || 5;

      this.root.addEventListener('click', () => { this.state.mode === 'read' ? this.state.mode = 'edit' : '' });
      this.root.addEventListener('focus', () => { this.state.mode === 'read' ? this.state.mode = 'edit' : '' });
      this.input.addEventListener('blur', () => { this.state.mode === 'edit' ? this.state.mode = 'read' : '' });
      this.addEventListener("input", ({ target }) => {
        if (!(target instanceof HTMLTextAreaElement)) return;

        this.updateHeight(target);
      });

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
        this.updateHeight(this.input);
        this.input.focus();

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
    this.output.innerHTML = marked.parse(this.input.value);
  }

  updateHeight(textareaEl) {
    if (this.isScrolling(textareaEl)) {
      this.grow(textareaEl);
    } else {
      this.shrink(textareaEl);
    }
  }

  valueIsDefault() {
    return this.input.value == this.defaultContent;
  }

  valueHasChanged() {
    return this.input.value.trim() !== this._contentBeforeEditing 
  }

  isScrolling(textareaEl) {
    return textareaEl.scrollHeight > textareaEl.clientHeight;
  }

  rows(textareaEl) {
    return textareaEl.rows;
  }

  grow(textareaEl) {
    // Store initial height of textarea
    let previousHeight = textareaEl.clientHeight;
    let rows = this.rows(textareaEl);

    while (this.isScrolling(textareaEl)) {
      rows++;
      textareaEl.rows = rows;

      // Get height after rows change is made
      const newHeight = textareaEl.clientHeight ;

      // If the height hasn't changed, break the loop
      // This is an important safety check in case the height is hard coded
      if (newHeight === previousHeight) break;

      // Store the updated height for the next comparison and proceed
      previousHeight = newHeight;
    }
  }

  /** Shrink until the textarea matches the minimum rows or starts overflowing */
  shrink(textareaEl) {
    // Store initial height of textarea
    let previousHeight = textareaEl.clientHeight;

    const minRows = parseInt(textareaEl.dataset.minRows);
    let rows = this.rows(textareaEl);

    while (!this.isScrolling(textareaEl) && rows > minRows) {
      rows--;
      textareaEl.rows = Math.max(rows, minRows);

      // Get height after rows change is made
      const newHeight = textareaEl.clientHeight;

      // If the height hasn't changed, break the loop
      // This is an important safety check in case the height is hard coded
      if (newHeight === previousHeight) break;

      // If we shrunk so far that we're overflowing, add a row back on.
      if (this.isScrolling(textareaEl)) {
        this.grow(textareaEl);
        break;
      }
    }
  }

  save() {
    if(this.submissionForm) {
      const hiddenInput = this.submissionForm.querySelector(`input[name="${this.id}"]`);
      if(hiddenInput) {
        hiddenInput.value = this.content;
      } else {
        const button = this.submissionForm.querySelector('button[type="submit], input[type="submit"]');
        const newHiddenInput = document.createElement('input');
        newHiddenInput.setAttribute('name', this.id);
        newHiddenInput.setAttribute('type', 'hidden');
        hiddenInput.value = this.content;
        button.insertAdjacentHTML('beforebegin', newHiddenInput);
      }
    }
  }

}

export default EditableContent
