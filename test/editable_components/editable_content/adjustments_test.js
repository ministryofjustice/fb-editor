
require('../../setup');
const {
  htmlAdjustment,
  markdownAdjustment
} = require('../../../app/javascript/src/shared/content');

describe('EditableContent', function() {
  const helpers = require('./helpers');
  const COMPONENT_ID = 'editable-content-adjustments-test';

  describe('Adjustments', function() {
    var created;
    var config = {
      htmlAdjustment: htmlAdjustment,
      markdownAdjustment: markdownAdjustment
    }

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    describe('GovSpeak CTA Markup support', function() {
      describe('HTML to markdown', function() {

        it('allows single line $cta block', function(){      
          const html = `<p>This is a paragraph</p>
          <p>$cta This is a call to action $cta</p>`;

          const markdown = 'This is a paragraph\n\n$cta\nThis is a call to action \n$cta\n\n';

          created = helpers.createEditableContent(COMPONENT_ID, config, html );

          expect(created.instance.markdown).to.eql(markdown);
        });

        it('allows linebreaks around before/after $cta tags', function(){      
          const html = `<p>This is a paragraph</p>
          <p>$cta
          This is a call to action
          $cta</p>`;

          const markdown = 'This is a paragraph\n\n$cta\nThis is a call to action \n$cta\n\n';

          created = helpers.createEditableContent(COMPONENT_ID, config, html );

          expect(created.instance.markdown).to.eql(markdown);
        });

        it('allows soft linebreaks within $cta contents', function(){      
          const html = `<p>This is a paragraph</p>
          <p>$cta
            This is my call to action<br>
            with a new line
            $cta</p>`;

          const markdown = 'This is a paragraph\n\n$cta\nThis is my call to action  \nwith a new line \n$cta\n\n';

          created = helpers.createEditableContent(COMPONENT_ID, config, html );

          expect(created.instance.markdown).to.eql(markdown);
        });

        it('allows multiple paragraphs within $cta block', function() {
          const html = `<p>This is a paragraph</p>
          <p>$cta
          This is my call to action.</p>

          <p>It contains two paragraphs.
          $cta</p>`;

          const markdown = 'This is a paragraph\n\n$cta\nThis is my call to action.\n\nIt contains two paragraphs. \n$cta\n\n';

          created = helpers.createEditableContent(COMPONENT_ID, config, html );

          expect(created.instance.markdown).to.eql(markdown);
        });

        it('allows multiple $cta blocks within a content area', function(){
          const html = `<p>This is a paragraph</p>
          <p>$cta
          This is my first call to action.</p>

          <p>It contains two paragraphs.
          $cta</p>

          <p>$cta
          This is the second call to action.
          $cta</p>`;

          const markdown = 'This is a paragraph\n\n$cta\nThis is my first call to action.\n\nIt contains two paragraphs. \n$cta\n\n$cta\nThis is the second call to action. \n$cta\n\n';

          created = helpers.createEditableContent(COMPONENT_ID, config, html );

          expect(created.instance.markdown).to.eql(markdown);
        });
      });
      
      describe('Markdown to HTML', function() {
        beforeEach(function() {
          created = helpers.createEditableContent(COMPONENT_ID, config, '' );
        })

        it('allows single line $cta block', function(){      
          const markdown = 'This is a paragraph\n\n$cta\nThis is a call to action \n$cta\n\n';
          const html = `<p>This is a paragraph</p>
<div class="call-to-action"><p>This is a call to action <br>
</p></div>`;

          created.instance.$input.val(markdown);
          created.instance.update()

          expect(created.instance.$output.html()).to.eql(html);
        });

        it('allows linebreaks around before/after $cta tags', function(){      
          const markdown = 'This is a paragraph\n\n$cta\nThis is a call to action \n$cta\n\n';
          const html = `<p>This is a paragraph</p>
<div class="call-to-action"><p>This is a call to action <br>
</p></div>`;

          created.instance.$input.val(markdown);
          created.instance.update()

          expect(created.instance.$output.html()).to.eql(html);
        });

        it('allows soft linebreaks within $cta contents', function(){      
          const markdown = 'This is a paragraph\n\n$cta\nThis is my call to action  \nwith a new line \n$cta\n\n';
          const html = `<p>This is a paragraph</p>
<div class="call-to-action"><p>This is my call to action  <br>
with a new line <br>
</p></div>`;

          created.instance.$input.val(markdown);
          created.instance.update()

          expect(created.instance.$output.html()).to.eql(html);
        });

        it('allows multiple paragraphs within $cta block', function() {
          const markdown = 'This is a paragraph\n\n$cta\nThis is my call to action.\n\nIt contains two paragraphs. \n$cta\n\n';
          const html = `<p>This is a paragraph</p>
<div class="call-to-action"><p>This is my call to action.</p>
<p>It contains two paragraphs. <br>
</p></div>`;

          created.instance.$input.val(markdown);
          created.instance.update()

          expect(created.instance.$output.html()).to.eql(html);
        });

        it('allows multiple $cta blocks within a content area', function(){
          const markdown = 'This is a paragraph\n\n$cta\nThis is my first call to action.\n\nIt contains two paragraphs. $cta\n\n$cta This is the second call to action. \n$cta\n\n';
          const html = `<p>This is a paragraph</p>
<div class="call-to-action"><p>This is my first call to action.</p>
<p>It contains two paragraphs. </p></div>
<div class="call-to-action"><p> This is the second call to action. <br>
</p></div>`;

          created.instance.$input.val(markdown);
          created.instance.update()

          expect(created.instance.$output.html()).to.eql(html);
        });
      });
    });
  });
});

