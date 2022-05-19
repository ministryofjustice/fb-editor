require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.updateHiddenInputOnForm', function() {
  const FORM_ID = "update-hidden-input-on-form-test";

  before(function() {
    var $form = $('<form></form>');
    $form.attr('id', FORM_ID);
    $(document.body).append($form);
  });

  it('should update an existing hidden form element', function() {
    var $form1 = $("#" + FORM_ID);
    utilities.addHiddenInpuElementToForm($form1, 'field2', 'field-2-content');

    expect($form1.find('[name=\'field2\']').val()).to.equal('field-2-content');

    utilities.updateHiddenInputOnForm($form1, 'field2', 'field-2-content-updated');

    expect($form1.find('[name=\'field2\']').val()).to.equal('field-2-content-updated');
  });

  after(function() {
    $("#" + FORM_ID).remove();
  });
});
