/**
 * Autocomplete Question
 * ----------------------------------------------------
 * Description:
 * Autocomplete component extension of a Question
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 *
 **/


const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const Question = require('./question');
const DialogForm = require('./component_dialog_form');

const SELECTOR_HINT = ".govuk-hint";
const SELECTOR_LABEL = "label h1, label h2, legend h1, legend h2";

class AutocompleteQuestion extends Question {
  constructor($node, config) {
    super($node, mergeObjects({
      // Add stuff here if you want to set defaults
      default_content: "empty",
      selectorLabel: SELECTOR_LABEL,
      selectorHint: SELECTOR_HINT
    }, config));

    $node.addClass("AutocompleteQuestion");

    const apiPath = this.menu.$items.filter('[data-action="upload"]').data('api-path');
    
    $node.find('.fb-govuk-button-inverted').on('click', function() {
      new DialogForm(apiPath, {
        activator: $node.find('.fb-govuk-button-inverted'),
        remote: true,
        autoOpen: true,
        submitOnClickSelector: 'input[type="submit"]',
        onSuccess: function(data) {
        },

        onError: function(data, dialog) {
          var responseHtml = $.parseHTML(data.responseText);
          var $newHtml = $(responseHtml[0]).html();
          dialog.$node.html($newHtml);
          dialog.refresh();
        },
      })
    });
  }
}


module.exports = AutocompleteQuestion;
