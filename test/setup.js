const expect = require("chai").expect;
const jsdom = require("jsdom");
const jquery = require('jquery');
const { JSDOM } = jsdom;

var dom = new JSDOM(`<html>
    <head>
      <title>Test document</title>
    </head>
    <body>
      <h1>Testing document</h1>
      <p>Nothing much here</p>
    </body>
  </html>`, {
    url: "http://localhost",
  });

  global.expect = expect;
  global.window = dom.window;
  global.document = window.document;
  global.jQuery = require( 'jquery' )( window );
  global.$ = jQuery;

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

