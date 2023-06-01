const chai = require("chai");
const expect = chai.expect;
const sinonChai = require("sinon-chai");
const chaiDom = require('chai-dom')
const jquery = require('jquery');

const cleanJSDOM = require('jsdom-global')(`<html>
     <head>
      <title>Test document</title>
    </head>
     <body>
       <h1>Testing document</h1>
       <p>Nothing much here</p>
     </body>
     </html>`, {
    url: "http://localhost",
  })

chai.use(sinonChai);
chai.use(chaiDom)

global.expect = expect;
global.cleanJSDOM = cleanJSDOM;
global.jQuery = jquery( global.window );
global.$ = jQuery;
global.sinon = require("sinon"); // sinon *must* be required after the above line

// Highjack form submits to inspect data
global.window.HTMLFormElement.prototype.submit = function() {
  var $form = $(this);
  $form.data("params", $form.serialize());
}

// Sort out jQuerUI requirements
require('jquery-ui/ui/widget');
require('jquery-ui/ui/unique-id');
require('jquery-ui/ui/widgets/button');
require('jquery-ui/ui/widgets/dialog');
require('jquery-ui/ui/widgets/menu');
require('jquery-ui/ui/safe-active-element');
require('jquery-ui/ui/data');
require('jquery-ui/ui/tabbable');
require('jquery-ui/ui/focusable');
require('jquery-ui/ui/safe-blur');

