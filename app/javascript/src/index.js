const DefaultController = require('./controller_default');
const PagesController = require('./controller_pages');
const ServicesController = require('./controller_services');
const FormListPage = require('./page_form_list');
const PublishController = require('./controller_publish');
const BranchesController = require('./controller_branches');
const FormAnalyticsController = require('./controller_form_analytics');


// Determine the controller we need to use
function controllerAndAction() {
  var controller = app.page.controller.charAt(0).toUpperCase() + app.page.controller.slice(1);
  return controller + "Controller#" + app.page.action;
}

// Fetch JSON data from server
function loadPageData(app) {
  $.ajax({
    url: app.page.data_url,
    async: false,
    dataType: "json",
    success: function(data) {
      app.text.defaults = data.meta.default_text;
    }
  });
}


// Set the controller we want to use.
// Initialise using doc.ready so everything is in place.
// app is global set inside app/view/partials/properties
//
var Controller;

switch(controllerAndAction()) {
  case "BranchesController#new":
  case "BranchesController#create":
  case "BranchesController#edit":
  case "BranchesController#update":
       Controller = BranchesController;
  break;

  case "ServicesController#index":
  case "ServicesController#create":
       Controller = FormListPage;
  break;

  case "ServicesController#edit":
       Controller = ServicesController;
  break;

  case "PagesController#edit":
  case "PagesController#create":
       Controller = PagesController;
       loadPageData(app);
  break;

  case "PublishController#index":
  case "PublishController#create":
       Controller = PublishController;
  break;

  case "Form_analyticsController#create":
  case "Form_analyticsController#index":
       Controller = FormAnalyticsController;
  break;

  default:
       console.log(controllerAndAction());
       Controller = DefaultController;
}

$(document).ready( () => new Controller(app) );
