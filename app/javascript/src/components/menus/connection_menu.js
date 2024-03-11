const {
  mergeObjects,
  post,
  updateHiddenInputOnForm,
} = require("../../utilities");
const ActivatedMenu = require("./activated_menu");
const DialogForm = require("../../component_dialog_form");

class ConnectionMenu extends ActivatedMenu {
  constructor($node, config) {
    super(
      $node,
      mergeObjects(
        {
          activator_classname: $node.data("activator-classname"),
          container_id: $node.data("activated-menu-container-id"),
          activator_text: $node.data("activator-text"),
        },
        config,
      ),
    );

    // Register event handler for selection of menu item.
    $node.on("menuselect", (event, ui) => {
      this.selection(event, ui.item);
    });

    this.activator.$node.addClass("ConnectionMenuActivator");
    this.container.$node.addClass("ConnectionMenu");
    this.title = $node.data("title");
    this.addPageAfter = $node.data("uuid");
    this.addPageAfterCondition = $node.data("condition-uuid");

    this.setAccessibleLabel();
  }

  setAccessibleLabel() {
    var nextUuid = this.$node.data("next-uuid");
    var nextItem = document.getElementById(nextUuid);
    if (nextItem) {
      const currentLabel = this.activator.$node.attr("aria-label");
      const nextLabel = $(nextItem).find(".text").text();
      this.activator.$node.attr(
        "aria-label",
        `${currentLabel} and ${nextLabel}`,
      );
    }
  }

  selection(event, item) {
    var action = item.data("action");

    switch (action) {
      case "none":
        // null action e.g. when we show submenu
        break;
      case "link":
        this.link(item);
        break;
      case "destination":
        this.changeDestination(item);
        break;
      case "reconnect-confirmation":
        this.reconnectConfirmation(item);
        break;
      default:
        this.addPage(item);
        break;
    }
  }

  addPage(element) {
    var dialog = this.config.view.pageAdditionDialog;
    var $form = dialog.$form;

    // Set the 'add_page_here' value to mark point of new page inclusion.
    // Should be a uuid of previous page or blank if at end of form.
    // If we are on a branch condition, then also set the condition uuid
    updateHiddenInputOnForm($form, "page[add_page_after]", this.addPageAfter);
    if (this.addPageAfterCondition) {
      updateHiddenInputOnForm(
        $form,
        "page[conditional_uuid]",
        this.addPageAfterCondition,
      );
    }

    // Then add any required values.
    updateHiddenInputOnForm(
      $form,
      "page[page_type]",
      element.data("page-type"),
    );
    updateHiddenInputOnForm(
      $form,
      "page[component_type]",
      element.data("component-type"),
    );

    this.config.view.pageAdditionDialog.open();
  }

  link(element) {
    var $link = element.find("> a");
    location.href = $link.attr("href");
  }

  // Open an API request dialog to change destination
  changeDestination(element) {
    var $link = element.find("> a");
    new DialogForm($link.attr("href"), {
      activator: $link,
      autoOpen: true,
      remote: false,
    });
  }

  reconnectConfirmation(element) {
    var url = element.data("url");
    var destinationUuid = element.data("destination-uuid");

    post(url, {
      destination_uuid: destinationUuid,
    });
  }
}
module.exports = ConnectionMenu;
