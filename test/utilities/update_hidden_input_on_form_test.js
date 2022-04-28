require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');


describe('utilities.updateHiddenInputOnForm', function() {
  before(function() {
    var $form = $('<form></form>');
    $form.attr('id', 'updateHiddenInputOnForm');
    $(document.body).append($form);
  });

  it('should update an existing hidden form element', function() {
    var $form1 = $('#updateHiddenInputOnForm');
    utilities.addHiddenInpuElementToForm($form1, 'field2', 'field-2-content');

    expect($form1.find('[name=\'field2\']').val()).to.equal('field-2-content');

    utilities.updateHiddenInputOnForm($form1, 'field2', 'field-2-content-updated');

    expect($form1.find('[name=\'field2\']').val()).to.equal('field-2-content-updated');
  });

  after(function() {
    $('#updateHiddenInputOnForm').remove();
  });
});
