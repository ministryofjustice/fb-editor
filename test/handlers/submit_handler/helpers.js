const SubmitHandler = require('../../../app/javascript/src/submit_handler.js');
const GlobalHelpers = require('../../helpers.js');

const constants = {
  BUTTON_CLASS: 'submit-handler-btn',
  BUTTON_DESCRIPTION_ID: 'button-description',
  DEFAULT_TEXT: 'Click Me',
  SUBMITTED_TEXT: 'Saved',
  SUBMITTING_TEXT: 'Saving',
  UNSUBMITTED_TEXT: 'Save',
  DESCRIPTION_TEXT: 'No Changes',
}

function setupView(id, useButton=false) {
  var form = `<form id="${id}" >
              </form>`;
  var button;

  if(useButton) {
    button = `<button class="${constants.BUTTON_CLASS}" type="submit" aria-describedby="btn-description">${constants.DEFAULT_TEXT}</button>`;
  } else {
    button = `<input class="${constants.BUTTON_CLASS}" type="submit" value="${constants.DEFAULT_TEXT}" aria-describedby="${constants.BUTTON_DESCRIPTION_ID}"/>`;
  }

  $('body').append(form);
  var $form =  $('body').find('#'+id);
  $form.append(button);
  $form.append(`<span id="${constants.BUTTON_DESCRIPTION_ID}"></span>`);

}

function createSubmitHandler(id, config={}) {
  var $form = $('#'+id);
  
  var conf = GlobalHelpers.mergeConfig({
    text: {
      submitted: constants.SUBMITTED_TEXT,
      unsubmitted: constants.UNSUBMITTED_TEXT,
      submitting: constants.SUBMITTING_TEXT,
      description: constants.DESCRIPTION_TEXT,
    }
  }, config);

  return {
    $form: $form,
    handler: new SubmitHandler($form, conf),
  }
}


function teardownView(id) {
  $("#"+ id).remove();
}

module.exports = {
  constants: constants,
  setupView: setupView,
  teardownView: teardownView,
  createSubmitHandler: createSubmitHandler
}
