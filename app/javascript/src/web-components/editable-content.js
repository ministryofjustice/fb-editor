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
    setTimeout(() => {
      this.initialMarkup = this.innerHTML;
      this.render();
    })
  }

  get initialContent() {
    return this.getAttribute('content').replace(/\\r\\n?|\\n/g, '\n');
  }

  get defaultContent() {
    return this.getAttribute('default-content');
  }

  get content() {
    return this.input.value == this.defaultContent ? '' : this.input.value;
  }

  set form(element) {
    this.submissionForm = element;
  }

  render() {
    const initialContent = this.initialContent || this.defaultContent;
    this.innerHTML = `
    <div class="editable-content" data-element="editable-content-root">
      <textarea class="govuk-textarea" data-element="editable-content-input" rows="10" hidden>${initialContent}</textarea>
      <div data-element="editable-content-output">${this.initialMarkup}</div>
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

    this.innerHTML = this.initialMarkup;
  }


  processStateChange() {
    this.root.setAttribute('mode', this.state.mode)

    switch(this.state.mode) {
      case 'edit':
        this._contentBeforeEditing = this.input.value.trim();
        this.input.removeAttribute('hidden')
        this.output.setAttribute('hidden', '')
        this.updateHeight(this.input);
        this.input.focus()
        if(this.input.value == this.defaultContent) {
          this.input.value = '';
        }
        this.input.selectionStart = this.input.value.length;
        break;
      case 'read':
      case 'initial':
        if(this.input.value.trim() == '') {
          this.input.value = this.defaultContent
        }
        this.renderContent();
        
        this.input.setAttribute('hidden', '')
        this.output.removeAttribute('hidden')
        if(this.input.value.trim() !== this._contentBeforeEditing ) {
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

  renderContent(){
    this.output.innerHTML = marked.parse(this.input.value);
  }

  updateHeight(textareaEl) {
    if (this.isScrolling(textareaEl)) {
      this.grow(textareaEl);
    } else {
      this.shrink(textareaEl);
    }
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
        hiddenInput.value = this.input.value;
      } else {
        const button = this.submissionForm.querySelector('button[type="submit], input[type="submit"]');
        const newHiddenInput = document.createElement('input');
        newHiddenInput.setAttribute('name', this.id);
        newHiddenInput.setAttribute('type', 'hidden');
        button.insertAdjacentHTML('beforebegin', newHiddenInput);
      }
    }
  }

}

export default EditableContent
