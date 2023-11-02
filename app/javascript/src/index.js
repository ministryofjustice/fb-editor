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

function parseUrl(resource) {
    const url = new URL(resource)
    const parts = url.pathname.split('/').filter(p => p)
    return parts
}

// Fetch JSON data from server
function loadPageData(app) {
    $.ajax({
        url: '/api/services/:id/pages/:page_uuid',
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
let Controller;

const setController = () => {
    const urlParts = parseUrl(window.location);

    const urlContains = (...needles) => {
        return needles.every((needle) => urlParts.indexOf(needle) !== -1)
    }

    switch (true) {
        case urlContains('branches'):
            Controller = BranchesController;
            app.page.action = 'create'
            break;

        case urlContains('pages'):
            Controller = PagesController;
            app.page.action = 'edit'
            loadPageData(app);
            break;

        case urlContains('publish'):
            Controller = PublishController;
            app.page.action = 'create'
            break;

        case urlContains('form_analytics'):
            Controller = FormAnalyticsController;
            app.page.action = 'index'
            break;

        case urlContains('submission', 'email'):
            Controller = CollectionEmailController;
            app.page.action = 'index'
            break;

        case urlContains('submission', 'confirmation_email'):
            Controller = ConfirmationEmailController;
            app.page.action = 'index'
            break;

        case urlContains('reference_payment'):
            Controller = ReferencePaymentController;
            app.page.action = 'index'
            break;

        case urlContains('services', 'edit'):
            Controller = ServicesController;
            app.page.action = 'edit'
            break;

        case urlContains('services') && urlParts.length == 1:
            Controller = FormListPage;
            break;

        default:
            Controller = DefaultController;
    }
}

setController()

document.addEventListener('turbo:load', () => {
    setController()
    console.log(Controller.name)
    new Controller(app);
    GOVUKFrontend.initAll();
});

