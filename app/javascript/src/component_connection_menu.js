const utilities = require('./utilities');
const mergeObjects = utilities.mergeObjects;
const ActivatedMenu = require('./component_activated_menu');
const DialogApiRequest = require('./component_dialog_api_request');

class ConnectionMenu extends ActivatedMenu {
  constructor($node, config) {
    super($node, mergeObjects({
      activator_classname: $node.data("activator-classname"),
      container_id: $node.data("activated-menu-container-id"),
      activator_text: $node.data("activator-text")
    }, config));

    this.container.$node.addClass("ConnectionMenu");

    // Register event handler for selection of menu item.
    $node.on("menuselect", (event, ui) => {
      this.selection(event, ui.item);
    });

    this.activator.$node.addClass("ConnectionMenuActivator");
    this.container.$node.addClass("ConnectionMenu");
    this.uuid = $node.data("uuid");
    this.title = $node.data("title");
  }

  set addPageAfter(uuid) {
    this._uuid = uuid;
  }

  get addPageAfter() {
    return this._uuid;
  }

  selection(event, item) {

    var action = item.data("action");
    
    event.preventDefault();

    switch(action) {
      case "none":
        // null action e.g. when we show submenu
        break;
      case "link": 
        this.link(item);
        break;
      case "destination":
        this.changeDestination(item);
        break;
      default:
        this.addPage(item);
        break;
      }

    }

    addPage(element) {
        var dialog = this._config.view.pageAdditionDialog;
        var $form = dialog.$form;
      
        // Set the 'add_page_here' value to mark point of new page inclusion.
        // Should be a uuid of previous page or blank if at end of form.
        utilities.updateHiddenInputOnForm($form, "page[add_page_after]", this.addPageAfter);

        // Then add any required values.
        utilities.updateHiddenInputOnForm($form, "page[page_type]", element.data("page-type"));
        utilities.updateHiddenInputOnForm($form, "page[component_type]", element.data("component-type"));

        this._config.view.pageAdditionDialog.open();
    } 
    
    link(element) {
      var $link = element.find("> a");
      location.href = $link.attr("href");
    }

    // Open an API request dialog to change destination
    changeDestination(element) {
      var view = this._config.view;
      var $link = element.find("> a");
      new DialogApiRequest($link.attr("href"), {
        activator: $link,
        buttons: [{
          text: view.text.dialogs.button_change_destination,
          click: function(dialog) {
            dialog.$node.find("form").submit();
          }
        }, {
          text: view.text.dialogs.button_cancel
        }]
      });
    }
  }
  module.exports = ConnectionMenu
