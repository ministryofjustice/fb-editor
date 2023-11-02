const DefaultController = require('./controller_default');
const PagesController = require('./controller_pages');
const ServicesController = require('./controller_services');
const FormListPage = require('./page_form_list');
const PublishController = require('./controller_publish');
const BranchesController = require('./controller_branches');
const FormAnalyticsController = require('./controller_form_analytics');
const CollectionEmailController = require('./controller_collection_email');
const ConfirmationEmailController = require('./controller_confirmation_email');
const ReferencePaymentController = require('./controller_reference_payment');
const GOVUKFrontend = require('govuk-frontend')

window.GOVUKFrontend = GOVUKFrontend

const {
    snakeToPascalCase,
} = require('./utilities');


// Determine the controller we need to use
function controllerAndAction() {
    var controller = snakeToPascalCase(app.page.controller);
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

switch (controllerAndAction()) {
    case "BranchesController#new":
    case "BranchesController#create":
    case "BranchesController#edit":
    case "BranchesController#update":
        Controller = BranchesController;
        break;

    case "ConditionalContentsController#new":
    case "ConditionalContentsController#create":
    case "ConditionalContentsController#edit":
    case "ConditionalContentsController#update":
        Controller = ContentVisibilityController;
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

    case "FormAnalyticsController#create":
    case "FormAnalyticsController#index":
        Controller = FormAnalyticsController;
        break;

    case "EmailController#index":
    case "EmailController#create":
        Controller = CollectionEmailController;
        break;

    case "ConfirmationEmailController#index":
    case "ConfirmationEmailController#create":
        Controller = ConfirmationEmailController;
        break;

    case "ReferencePaymentController#index":
    case "ReferencePaymentController#create":
        Controller = ReferencePaymentController;
        break;

    default:
        //console.log(controllerAndAction());
        Controller = DefaultController;
}

document.addEventListener('turbo:load', () => {
    new Controller(app);
    GOVUKFrontend.initAll();
});

document.addEventListener("turbo:before-render", (event) => {

    console.log(event)
})
