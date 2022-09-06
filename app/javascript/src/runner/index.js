const {
  htmlAdjustment,
  markdownAdjustment
} = require('../shared/content');


/* Enhances the edited content should it require special formatting
 * or non-standard elements.
 * e.g.
 *  - Adds GovUk classes to any <table> element
 *  - Changes supported GovSpeak markup to required HTML.
 **/
function supportGovUkContent() {
  $("[data-fb-content-type=content]").each(function() {
    var $this = $(this);
    $this.html(htmlAdjustment($this.html()));
  });
}


/* Page initialiser section
 **/
$(document).ready( () => {
  supportGovUkContent();
});
