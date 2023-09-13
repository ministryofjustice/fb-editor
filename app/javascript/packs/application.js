// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Scripts called by javascript_pack_tag
require('@ungap/custom-elements'); // required until safari supports customizing native elements using `is`
require("jquery")
require("jquery-ui")
require("../src/index")

import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

import DynamicFieldsController from '../src/controllers/dynamic-fields-controller.js'
import ConditionalController from '../src/controllers/conditional-controller.js'
import ConditionalsController from '../src/controllers/conditionals-controller.js'
import ExpressionController from '../src/controllers/expression-controller.js'
import ExpressionsController from '../src/controllers/expressions-controller.js'
import ExpressionConditionController from '../src/controllers/expression-condition-controller.js'

Turbo.session.drive = false
window.Stimulus = Application.start()
Stimulus.register("dynamic-fields", DynamicFieldsController)
Stimulus.register("conditional", ConditionalController)
Stimulus.register("conditionals", ConditionalsController)
Stimulus.register("expression", ExpressionController)
Stimulus.register("expressions", ExpressionsController)
Stimulus.register("expression-condition", ExpressionConditionController)

const { EditableContent } = require('../src/web-components/editable-content');
const { ElasticTextarea } = require('../src/web-components/elastic-textarea');
const { SaveButton } = require('../src/web-components/save-button');
// const { ConditionalQuestionSelect } = require('../src/web-components/conditional-question-select');

if ('customElements' in window) {
  customElements.define('elastic-textarea', ElasticTextarea);
  customElements.define('editable-content', EditableContent);
  customElements.define('save-button', SaveButton, { extends: 'button'});
  // customElements.define('conditional-question-select', ConditionalQuestionSelect);
}

// Entry point for fb-editor stylesheets
import "../styles/application.scss"


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
global.images = require.context('../images', true)
global.imagePath = (name) => images(name, true)
