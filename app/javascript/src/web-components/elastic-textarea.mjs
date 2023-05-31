class ElasticTextarea extends HTMLElement {
  constructor() {
    super()
  }

  connectedCallback() {
    this.textarea = this.querySelector("textarea")
    if(!this.textarea) return
    
    this.update()

    // Use event delegation to listen for textarea inputs and update the areas
      this.textarea.addEventListener("input", () => {
        this.update()
      });
  }

  get isScrolling() {
    return this.textarea.scrollHeight > this.textarea.clientHeight;
  }

  get rows() {
    return this.textarea.rows;
  }

  update() {
    if (this.isScrolling) {
      this.grow();
    } else {
      this.shrink();
    }
  }

  grow() {
    // Store initial height of textarea
    let previousHeight = this.textarea.clientHeight;
    let rows = this.rows;

    while (this.isScrolling) {
      rows++;
      this.textarea.rows = rows;

      // Get height after rows change is made
      const newHeight = this.textarea.clientHeight ;

      // If the height hasn't changed, break the loop
      // This is an important safety check in case the height is hard coded
      if (newHeight === previousHeight) break;

      // Store the updated height for the next comparison and proceed
      previousHeight = newHeight;
    }
  }

  /** Shrink until the textarea matches the minimum rows or starts overflowing */
  shrink() {
    // Store initial height of textarea
    let previousHeight = this.textarea.clientHeight;

    const minRows = parseInt(this.textarea.dataset.minRows);
    let rows = this.rows;

    while (!this.isScrolling && rows > minRows) {
      rows--;
      this.textarea.rows = Math.max(rows, minRows);

      // Get height after rows change is made
      const newHeight = this.textarea.clientHeight;

      // If the height hasn't changed, break the loop
      // This is an important safety check in case the height is hard coded
      if (newHeight === previousHeight) break;

      // If we shrunk so far that we're overflowing, add a row back on.
      if (this.isScrolling) {
        this.grow();
        break;
      }
    }
  }
}
export { ElasticTextarea }
