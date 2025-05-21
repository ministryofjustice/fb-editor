/**
 * Textarea Question
 * ----------------------------------------------------
 * Description:
 * Textarea component extension of Question
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

const SELECTOR_HINT = "[data-fb-node=hint]";
const SELECTOR_LABEL = "label h1 span , label h2 span";

class TextareaQuestion extends Question {
  constructor($node, config) {
    super(
      $node,
      mergeObjects(
        {
          // Add stuff here if you want to set defaults
          selectorLabel: SELECTOR_LABEL,
          selectorHint: SELECTOR_HINT,
        },
        config,
      ),
    );

    $node.addClass("TextareaQuestion");
  }
}

module.exports = TextareaQuestion;
