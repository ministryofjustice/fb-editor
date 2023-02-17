require('../../setup');

describe('EditableContent', function() {
  const helpers = require('./helpers');
  const c = helpers.constants;
  const COMPONENT_ID = 'editable-content-methods-test';

  describe('Methods', function() {
    var created;

    beforeEach(function() {
      created = helpers.createEditableContent(COMPONENT_ID);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    describe('get content()',function() {
      it('should return markdown if no config data', function() {
        delete created.instance._config.data;

        expect(created.instance.content).to.equal(c.MARKDOWN_CONTENT);
      });

      it('should return json if config data is present', function(){
        const data = {
          content: c.MARKDOWN_CONTENT,
          _uuid: c.UUID,
        }
        expect(JSON.parse(created.instance.content)).to.have.all.keys(['content', '_uuid'])
        expect(JSON.parse(created.instance.content)).to.eql(data)
      });

      it('should return content as an empty string if it matches the default', function(){
        created.instance.content = c.DEFAULT_CONTENT;
        const data = {
          content: '',
          _uuid: c.UUID,
        }
        expect(JSON.parse(created.instance.content)).to.have.all.keys(['content', '_uuid'])
        expect(JSON.parse(created.instance.content)).to.eql(data)
      });
    });

    describe('set content()', function() {
      it('should store the provided content', function() {
        const updated_content =  '## My new markdown\n\nA paragraph'
        created.instance.content = updated_content;

        expect(created.instance.markdown).to.equal(updated_content)
      });
    });

    describe('get markdown()', function() {
      it('should return the markdown', function() {
        expect(created.instance.markdown).to.equal(c.MARKDOWN_CONTENT)
      });
    });

    describe('edit()', function(){
      it('should apply the editClassname to the $node', function() {
        expect(created.instance.$node.hasClass(c.EDIT_CLASSNAME)).to.be.false;
        created.instance.edit();
        expect(created.instance.$node.hasClass(c.EDIT_CLASSNAME)).to.be.true;
      });

      it('should add the markdown to the $input', function() {
        created.instance.$input.val('');
        created.instance.edit();
        expect(created.instance.$input.val()).to.equal(c.MARKDOWN_CONTENT);
      });

      it('should focus the input', function() {
        const el = created.instance.$input.get(0);
        created.instance.edit();
        expect(document.activeElement).to.eql(el);
      });
    });

    describe('focus()', function(){
     it('should apply the editClassname to the $node', function() {
        expect(created.instance.$node.hasClass(c.EDIT_CLASSNAME)).to.be.false;
        created.instance.edit();
        expect(created.instance.$node.hasClass(c.EDIT_CLASSNAME)).to.be.true;
      });

      it('should add the markdown to the $input', function() {
        created.instance.$input.val('');
        created.instance.edit();
        expect(created.instance.$input.val()).to.equal(c.MARKDOWN_CONTENT);
      });

      it('should focus the input', function() {
        const el = created.instance.$input.get(0);
        created.instance.edit();
        expect(document.activeElement).to.eql(el);
      });

    });

    describe('update()', function(){
      it('should remove the editClassname from the $node', function() {
        created.instance.edit();
        expect(created.instance.$node.hasClass(c.EDIT_CLASSNAME)).to.be.true;
        created.instance.update();
        expect(created.instance.$node.hasClass(c.EDIT_CLASSNAME)).to.be.false;
      });

      it('should update the markdown', function() {
        const updated_content =  '## My new markdown\n\nA paragraph'
        created.instance.$input.val(updated_content);

        created.instance.update();
        expect(created.instance.markdown).to.equal(updated_content);
      });

      it('should output the defaultContent if $input is empty', function(){
        created.instance.$input.val('');
        created.instance.update();
        expect(created.instance.$output.html()).to.equal(`<p>${c.DEFAULT_CONTENT}</p>`)
      });

      it('should add the html to the $output element', function(){
        const updated_content =  '## My new markdown\n\nA paragraph'
        created.instance.$input.val(updated_content);

        created.instance.update();

        expect(created.instance.$output.html()).to.equal(`<h2>My new markdown</h2>\n<p>A paragraph</p>`);
      });
    });

  });
});
