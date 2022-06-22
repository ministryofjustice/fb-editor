require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');



describe('utilities.addHiddenInpuElementToForm', function() {
  const ELEMENT_ID = "add-hidden-input-element-to-form-test";

  before(function() {
    var $form = $('<form></form>');
    $form.attr('id', ELEMENT_ID);
    $(document.body).append($form);
  });

  it('should add a new hidden form element to specified form if does not exist', function() {
    const CONTENT = 'field-1-content';
    var $form = $('#' + ELEMENT_ID);
    utilities.addHiddenInpuElementToForm($form, 'field1', CONTENT);

    expect($form.find('[name=\'field1\']').val()).to.equal(CONTENT);
  });

  after(function() {
    $('#' + ELEMENT_ID).remove();
  });
});
