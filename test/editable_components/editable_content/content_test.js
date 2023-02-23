require('../../setup');

describe('EditableContent', function() {
  const helpers = require('./helpers');
  const COMPONENT_ID = 'editable-content-content-test';

  const DIRTY_MARKDOWN = `
# My content

This is my lovely content. It has problems.

Here is a link [click me](<https://google.com>).

Here is an email address <email@address.com> it should come out as a link

> This is a blockquote.

Followed by another paragraph

## What about a list or two?

- Item 1
  - Item 1.1
- Item 2
- Item 3

1. First
  1. One point oneth
  2. One point twoeth
2. Second
3. Third

And one final paragraph.

`

  const CLEAN_MARKDOWN = `# My content

This is my lovely content. It has problems.

Here is a link [click me](https://google.com).

Here is an email address <email@address.com> it should come out as a link

> This is a blockquote.

Followed by another paragraph

## What about a list or two?

- Item 1
  - Item 1.1
- Item 2
- Item 3

1. First
  1. One point oneth
  2. One point twoeth
2. Second
3. Third

And one final paragraph.`

  const CLEAN_HTML = `<h1>My content</h1>
<p>This is my lovely content. It has problems.</p>
<p>Here is a link <a href="https://google.com">click me</a>.</p>
<p>Here is an email address <a href="mailto:email@address.com">email@address.com</a> it should come out as a link</p>
<blockquote>
  <p>This is a blockquote.</p>
</blockquote>
<p>Followed by another paragraph</p>
<h2>What about a list or two?</h2>
<ul>
<li>Item 1<ul>
<li>Item 1.1</li></ul></li>
<li>Item 2</li>
<li>Item 3</li>
</ul>
<ol>
<li>First<ol>
<li>One point oneth</li>
<li>One point twoeth</li></ol></li>
<li>Second</li>
<li>Third</li>
</ol>
<p>And one final paragraph.</p>`

  describe('Content', function() {
    var created;

    beforeEach(function() {
      created = helpers.createEditableContent(COMPONENT_ID);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    it('should remove <!-- --> from content', function() {
      created.instance.$input.val(DIRTY_MARKDOWN);
      created.instance.update();
      expect(created.instance.markdown).to.not.include('<!-- -->');
    });

    it('should remove angle brackets from links created by showdown', function() {
      created.instance.$input.val(DIRTY_MARKDOWN);
      created.instance.update();
      expect(created.instance.markdown).to.not.include('[click me](<https://google.com>)');
      expect(created.instance.markdown).to.include('[click me](https://google.com)');
    });

    it('should contain mailto link <email@address.com>', function() {
      created.instance.$input.val(DIRTY_MARKDOWN);
      created.instance.update();
      expect(created.instance.markdown).to.not.include('$mailtoemail@address.com$mailto');
      expect(created.instance.markdown).to.include('<email@address.com>');
    });

    it('should contain correct markdown blockquote syntax', function() {
      created.instance.$input.val(DIRTY_MARKDOWN);
      created.instance.update();
      expect(created.instance.markdown).to.not.include('&gt; This is a blockquote');
      expect(created.instance.markdown).to.include('> This is a blockquote');

    });


    it('should output correct markdown', function() {
      created.instance.$input.val(DIRTY_MARKDOWN);
      created.instance.update();
      expect(created.instance.markdown).to.equal(CLEAN_MARKDOWN);
    });

    it('should output correct html', function() {
      created.instance.$input.val(DIRTY_MARKDOWN);
      created.instance.update();
      let html = $(document).find('.EditableContent .output').html();
      expect(html).to.equal(CLEAN_HTML);
    });

  });
});
