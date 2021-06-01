/**
 * Question
 * ----------------------------------------------------
 * Description:
 * Basic construct of a standard question
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const Question = require('./question');

const SELECTOR_HINT = ".govuk-hint";
const SELECTOR_LABEL = "label h1, label h2, legend h1, legend h2";

class TextComponent extends Question {
  constructor($node, config) {
    super($node, mergeObjects({
      // Add stuff here if you want to set defaults
      default_content: "empty",
      selectorTextFieldLabel: SELECTOR_LABEL,
      selectorTextFieldHint: SELECTOR_HINT
    }, config));
  }
}


module.exports = TextComponent;
