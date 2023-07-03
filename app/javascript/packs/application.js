// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Scripts called by javascript_pack_tag
require("jquery")
require("jquery-ui")
require("../src/index")

const { EditableContent } = require('../src/web-components/editable-content');
const { ElasticTextarea } = require('../src/web-components/elastic-textarea');

if ('customElements' in window) {
  customElements.define('elastic-textarea', ElasticTextarea);
  customElements.define('editable-content', EditableContent);
}

// Entry point for fb-editor stylesheets
import "../styles/application.scss"


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
global.images = require.context('../images', true)
global.imagePath = (name) => images(name, true)
