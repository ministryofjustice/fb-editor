require('../../setup.js');

describe('SubmitHandler', function() {

  const helpers = require('./helpers.js');
  const c  = helpers.constants;
  const COMPONENT_ID = 'submit-handler-methods-test';

  describe('Methods', function() {
    var created;

    before( function() {
      helpers.setupView(COMPONENT_ID);
      created = helpers.createSubmitHandler(COMPONENT_ID);
    })

    after(function(){
      helpers.teardownView(COMPONENT_ID);
    }) 

    it('should have a setter for submittable property', function() {
      expect(created.handler.submittable).to.be.true;

      created.handler.submittable = false;
      expect(created.handler.submittable).to.be.false;

      created.handler.submittable = true;
      expect(created.handler.submittable).to.be.true;
    });

    it('should submit if #submitEnabled is false', function() {
      var submitted = false;
      created.$form.on('submit', (event) => submitted = true );

      created.handler.submittable = false;
      created.handler.submit();

      expect(submitted).to.be.true;

    })

  });

});
