const Branch = require("../../app/javascript/src/component_branch.js");


const constants = {
  CLASSNAME_BRANCH_ERROR_MESSAGE: "test-error-message",
  CLASSNAME_ERROR_1: "error-classname-1",
  CLASSNAME_ERROR_2: "error-classname-2",

  SELECTOR_PRE_BRANCH_DESTINATION: ".destination",
  SELECTOR_PRE_BRANCH_CONDITION: ".condition",
  SELECTOR_PRE_BRANCH_CONDITION_INJECTOR: ".condition-injector",
  SELECTOR_PRE_BRANCH_CONDITION_REMOVER: ".condition-remover",
  SELECTOR_PRE_BRANCH_QUESTION: ".question",
  SELECTOR_PRE_BRANCH_ANSWER: ".answer",
  SELECTOR_PRE_BRANCH_REMOVER: ".branch-remover",

  SELECTOR_BRANCH_DESTINATION: ".BranchDestination",
  SELECTOR_BRANCH_CONDITION: ".BranchCondition",
  SELECTOR_BRANCH_CONDITION_INJECTOR: ".BranchConditionInjector",
  SELECTOR_BRANCH_CONDITION_REMOVER: ".BranchConditionRemover",
  SELECTOR_BRANCH_QUESTION: ".BranchQuestion",
  SELECTOR_BRANCH_ANSWER: ".BranchAnswer",
  SELECTOR_BRANCH_REMOVER: ".BranchRemover",

  TEXT_BRANCH_REMOVE: "remove branch text",
  TEXT_CONDITION_ADD: "add condition text",
  TEXT_CONDITION_REMOVE: "remove condition text",
  TEXT_ERROR_MESSAGE: "This is an error message",
  TEXT_LABEL_QUESTION_AND: "And",
  TEXT_LABEL_QUESTION_IF: "If",

  URL_ANSWER: "/not/needed"
}


const view = {
             text: {
               branches: {
                 condition_add: constants.TEXT_CONDITION_ADD,
                 condition_remove: constants.TEXT_CONDITION_REMOVE
               },
               dialogs: {
                 heading_delete_condition: "Heading delete condition",
                 button_delete_message: "Message delete condition",
                 button_delete_condition: "Button delete condition",
                 heading_delete_branch: "Heading delete branch",
                 message_delete_branch: "Message delete branch",
                 button_delete_branch: "Button delete branch"
               },
               errors: {
                 branches: {
                   unsupported_question: constants.TEXT_ERROR_MESSAGE
                 }
               }
             }
           }



/* Creates a new branch from only passing in an id and optional config.
 *
 * @id     (String) String used to assign unique ID value.
 * @config (Object) Optional config can be passed in to override the defaults.
 *
 * Returns the following object:
 *
 * {
 *   branch: <branch instance created>
 *   html: <html used to simulate template rendition of pre-created branch>
 *   $node: <jQuery enhanced node (before branch instantiation) of the html>
 *  }
 *
 **/
function createBranch(id, config) {
  var html = `<div class="branch" id="` + id + `">
      <p>Branch ...</p>
      <ul class="govuk-navigation component-activated-menu">
        <li>
          <a class="branch-remover">` + constants.TEXT_BRANCH_REMOVE + `</a>
        </li>
      </ul>
      <div class="condition">
        <div class="question">
          <label for="branch_1">If</label>
          <select id="branch_1">
            <option value="">--Select a question--</option>
            <option value="a24f492b" data-supports-branching="true">Supported Question</option>
            <option value="b34f593a" data-supports-branching="false">Unsupported Question</option>
          </select>
        </div>
        <div class="answer">
          <select><option>is</option></select>
          <select><option>This answer value</option></select>
        </div>
        <button class="condition-remover">` + constants.TEXT_REMOVE_BRANCH + `</button>
      </div>
      <button class="condition-injector">` + constants.TEXT_CONDITION_ADD + `</button>
      <div class="destination">
        <div class="form-group">
          <label for="branch_next">Go to</label>
          <select id="branch_next">
            <option value="">--- Select a destination page ---</option>
            <option value="618a037b">Service name goes here</option>
            <option value="088dcdbe">Question</option>
            <option value="4d707045">Title</option>
          </select>
        </div>
      </div>
    </div>`;

  var $node = $(html);
  var conf = {
               index: 4,
               css_classes_error: constants.ERROR_CLASSNAME_1 + " " + constants.CLASSNAME_ERROR_2,
               selector_answer: constants.SELECTOR_PRE_BRANCH_ANSWER,
               selector_branch_remove: constants.SELECTOR_PRE_BRANCH_REMOVER,
               selector_condition: constants.SELECTOR_PRE_BRANCH_CONDITION,
               selector_condition_add: constants.SELECTOR_PRE_BRANCH_CONDITION_INJECTOR,
               selector_condition_remove: constants.SELECTOR_PRE_BRANCH_CONDITION_REMOVER,
               selector_destination: constants.SELECTOR_PRE_BRANCH_DESTINATION,
               selector_question: constants.SELECTOR_PRE_BRANCH_QUESTION,
               selector_error_messsage: "." + constants.CLASSNAME_BRANCH_ERROR_MESSAGE,
               answer_url: constants.URL_ANSWER,
               template_condition: "<div class=\"condition\">dummy</div>",
               confirmation_remove: false,
               view: view
             }

  // Include any passed config items.
  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  return {
    html: html,
    $node: $node,
    branch: new Branch($node, conf)
  }
}


module.exports = {
  constants: constants,
  createBranch: createBranch
}
