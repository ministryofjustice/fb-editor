/**
 * Date Question
 * ----------------------------------------------------
 * Description:
 * Date component extension of Question
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 **/


const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const Question = require('./question');

const SELECTOR_HINT = ".govuk-hint";
const SELECTOR_LABEL = "legend > :first-child";

class DateQuestion extends Question {
  constructor($node, config) {
    super($node, mergeObjects({
      // Add stuff here if you want to set defaults
      selectorLabel: SELECTOR_LABEL,
      selectorHint: SELECTOR_HINT
    }, config));

    $node.addClass("DateQuestion");
  }
}


module.exports = DateQuestion;
