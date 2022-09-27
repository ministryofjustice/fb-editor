require('../../setup.js');

describe('SubmitHandler', function() {

  const helpers = require('./helpers.js');
  const c  = helpers.constants;
  const COMPONENT_ID = 'submit-handler-properties-test';

  describe('Properties', function() {
    var created;

    before( function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createSubmitHandler(COMPONENT_ID);
    })

    after(function(){
      helpers.teardownView(COMPONENT_ID);
    }) 

    it("should have a public submittable property", function() {
       expect( created.handler.submittable ).to.be.true
    });

    it("should make the form public", function() {
      $form = $('#'+COMPONENT_ID);

      expect(created.handler.$form).to.exist;
      expect(created.handler.$form.length).to.eq(1);
      expect(created.handler.$form.get(0)).to.eq($form.get(0));
    })

    it("should make the button public", function() {
      $button = $('#'+COMPONENT_ID).find(':submit');

      expect(created.handler.$button).to.exist;
      expect(created.handler.$button.length).to.eq(1);
      expect(created.handler.$button.get(0)).to.eq($button.get(0));
    });

    it("should make the button description public", function() {
      $buttonDescription = $('#'+c.BUTTON_DESCRIPTION_ID);

      expect(created.handler.$buttonDescription).to.exist;
      expect(created.handler.$buttonDescription.length).to.eq(1);
      expect(created.handler.$buttonDescription.get(0)).to.eq($buttonDescription.get(0));
    })

  });
});
