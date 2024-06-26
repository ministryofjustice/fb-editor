/**
 * Text Question
 * ----------------------------------------------------
 * Description:
 * Text component extension of a Question
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 **/

const utilities = require("./utilities");
const mergeObjects = utilities.mergeObjects;
const Question = require("./question");

const SELECTOR_HINT = ".govuk-hint";
const SELECTOR_LABEL = "label h1 span, label h2 span";

class TextQuestion extends Question {
  constructor($node, config) {
    super(
      $node,
      mergeObjects(
        {
          // Add stuff here if you want to set defaults
          default_content: "empty",
          selectorLabel: SELECTOR_LABEL,
          selectorHint: SELECTOR_HINT,
        },
        config,
      ),
    );

    $node.addClass("TextQuestion");
  }
}

module.exports = TextQuestion;
