require('../../setup.js');

describe('SubmitHandler', function() {

  const helpers = require('./helpers.js');
  const c  = helpers.constants;
  const COMPONENT_ID = 'submit-handler-behaviours-test';

  describe('Behaviours', function() {
    describe('with input[type="submit"]', function() {
      var created;

      before( function() {
        helpers.setupView(COMPONENT_ID);
        created = helpers.createSubmitHandler(COMPONENT_ID);
        // sinon.spy(created.handler);
      })

      after(function(){
        helpers.teardownView(COMPONENT_ID);
        // sinon.restore();
      }) 

      it("should have the default text initially", function() {
        expect( created.handler.$button.val() ).to.eql(c.DEFAULT_TEXT);
      });

      it('should have the unsubmitted text when enabled', function() {
        created.handler.submittable = true
        expect( created.handler.$button.val() ).to.eql(c.UNSUBMITTED_TEXT);
      })

      it('should reset the description text when enabled', function() {
        created.handler.submittable = true
        expect( created.handler.$buttonDescription.text() ).to.eql('');
      });

      it('should set aria-dsibaled to false when enabled', function() { 
        created.handler.submittable = true
        expect( created.handler.$button.attr('aria-disabled')).to.eql('false')
      });

      it('should have the submitted text when disabled', function() {
        created.handler.submittable = false; 
        expect( created.handler.$button.val() ).to.eql(c.SUBMITTED_TEXT);
      });
      
      it('should set the description text when disabled', function() {
        created.handler.submittable = false
        expect( created.handler.$buttonDescription.text() ).to.eql(c.DESCRIPTION_TEXT);
      });

      it('should set aria-disabled to true when disabled', function() {

        created.handler.submittable = false
        expect( created.handler.$button.attr('aria-disabled')).to.eql('true')
      })

      it('should have the submitting text when button is clicked', function() {
        created.handler.submittable = true;

        created.$form.on('submit', (e) => e.preventDefault()  );

        created.handler.$button.click();

        expect( created.handler.$button.val() ).to.eql(c.SUBMITTING_TEXT);
      });

      it('should prevent submit when disabled', function() {
        var submitted = false;
        created.handler.submittable = false;
        created.$form.on('submit', () => submitted = true);
        
        created.handler.$button.click();

        expect(submitted).to.be.false;
      });

      it('should allow submit when enabled', function() {
        var submitted = false;
        created.handler.submittable = true;
        created.$form.on('submit', () => submitted = true);
        
        created.handler.$button.click();

        expect(submitted).to.be.true;
      });
      
    });

    describe('with button[type="submit"]', function() {

      var created;

      before( function() {
        helpers.setupView(COMPONENT_ID, true);
        created = helpers.createSubmitHandler(COMPONENT_ID);
        // sinon.spy(created.handler);
      })

      after(function(){
        helpers.teardownView(COMPONENT_ID);
        // sinon.restore();
      }) 

      it("should have the default text initially", function() {
        expect( created.handler.$button.text() ).to.eql(c.DEFAULT_TEXT);
      });

      it('should have the unsubmitted text when enabled', function() {
        created.handler.submittable = true
        expect( created.handler.$button.text() ).to.eql(c.UNSUBMITTED_TEXT);
      })

      it('should have the submitted text when disabled', function() {
        created.handler.submittable = false; 
        expect( created.handler.$button.text() ).to.eql(c.SUBMITTED_TEXT);
      })

      it('should have the submitting text when button is clicked', function() {
        created.handler.submittable = true;

        created.$form.on('submit', (e) => e.preventDefault()  );

        created.handler.$button.click();

        expect( created.handler.$button.text() ).to.eql(c.SUBMITTING_TEXT);
      });
    });


  });
});
