// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()

import accessibleAutocomplete from "accessible-autocomplete";

const elements = document.querySelectorAll('.fb-autocomplete');

Array.prototype.forEach.call(elements, function(element) {
  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: '',
    autoselect: false,
    showAllValues: true,
    selectElement: element,
  });
});

//window.analytics = require("../src/analytics")

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)



/*********************************************
 * EDITOR ONLY ADDITIONS BELOW.
 *********************************************/

// Little bit hacky but we want to prevent the
// Cookie banner from showing in preview mode.
const cookieBanner = document.getElementById("govuk-cookie-banner");
if(cookieBanner) {
  cookieBanner.style.display = "none";
}
