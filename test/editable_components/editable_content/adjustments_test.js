
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

    beforeEach(function() {
      // created = helpers.createEditableContent(COMPONENT_ID);
    });

    afterEach(function() {
      helpers.teardownView(COMPONENT_ID);
      created = undefined;
    });

    describe('GovSpeak CTA Markup support', function() {
      it('works without <br> tags', function(){      
        const html = `<p>This is a paragraph</p>
          <p>$cta This is a call to action $cta</p>`;

        created = helpers.createEditableContent(COMPONENT_ID, config, html );

        expect(created.instance.markdown).to.eql('This is a paragraph\n\n$cta\nThis is a call to action \n$cta\n\n');
      });

      it('works with soft linebreaks', function(){      
        const html = `<p>This is a paragraph</p>
          <p>$cta 
          This is a call to action  <br> with a soft linebreak 
        $cta</p>`;

        created = helpers.createEditableContent(COMPONENT_ID, config, html );

        expect(created.instance.markdown).to.eql('This is a paragraph\n\n$cta\nThis is a call to action  \nwith a soft linebreak $cta\n\n');
      });
    });

  });

  

});

