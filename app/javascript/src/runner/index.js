const {
  htmlAdjustment
} = require('../shared/content');
require('../shared/multiupload')

const ENVIRONMENT_PREVIEW = "preview";
const ENVIRONMENT_RUNNER = "runner";


/* Discover what environment we're playing in by checking the URL
 **/
function environment() {
  return location.pathname.search(/^\/services\/.*?\/preview\/$/) >= 0 ? ENVIRONMENT_PREVIEW : ENVIRONMENT_RUNNER;
}


/* Stop cookie banner from showing in preview mode.
 * We don't need cookie or analytics related warnings
 * in the preview.
 **/
function preventCookieBannerInPreview() {
  var cookieBanner = document.getElementById("govuk-cookie-banner");
  if(cookieBanner && environment() ==  ENVIRONMENT_PREVIEW) {
    cookieBanner.style.display = "none";
  }
}


/* Enhances the edited (or static) content should it require special formatting
 * or non-standard elements.
 * e.g.
 *  - Adds GovUk classes to any <table> element
 *  - Changes supported GovSpeak markup to required HTML.
 **/
function supportGovUkContent() {
  var content = document.querySelectorAll("[data-fb-content-type=content], [data-fb-content-type=static]");
  for( var c=0; c<content.length; ++c) {
    content[c].innerHTML = htmlAdjustment(content[c].innerHTML);
  }
}

function initializeMultifileUploadPage() {
  const addAnotherButton  = document.querySelector('[data-multiupload-element="add-another-file"]');

  if(!addAnotherButton) return;

  addAnotherButton.addEventListener('click', function(e) {
    e.preventDefault();
    window.multiupload.showFileUpload();
  })
}


/* Page initialiser section
 **/
contentLoaded(window, () => {
  preventCookieBannerInPreview();
  supportGovUkContent();
  initializeMultifileUploadPage();
});
