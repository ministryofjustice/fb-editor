require("../setup");
const utilities = require('../../app/javascript/src/utilities.js');



describe('utilities.addHiddenInpuElementToForm', function() {
  before(function() {
    var $form = $('<form></form>');
    $form.attr('id', 'addHiddenInpuElementToForm');
    $(document.body).append($form);
  });

  it('should add a new hidden form element to specified form if does not exist', function() {
    var $form = $('#addHiddenInpuElementToForm');
    utilities.addHiddenInpuElementToForm($form, 'field1', 'field-1-content');

    expect($form.find('[name=\'field1\']').val()).to.equal('field-1-content');
  });

  after(function() {
    $('#addHiddenInpuElementToForm').remove();
  });
});
