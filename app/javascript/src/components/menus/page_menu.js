const { mergeObjects, post } = require("../../utilities");
const ActivatedMenu = require("./activated_menu");
const DialogApiRequest = require("../../component_dialog_api_request");
const DialogForm = require("../../component_dialog_form");

class PageMenu extends ActivatedMenu {
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

    $node.on("menuselect", (event, ui) => {
      this.selection(event, ui.item);
    });

    this.activator.$node.addClass("PageMenuActivator");
    this.container.$node.addClass("PageMenu");
    this.uuid = $node.data("uuid");
    this.title = $node.data("title");
  }

  // Handle item selections on the form step context menu elements.
  selection(event, item) {
    event.preventDefault();
    var action = item.data("action");

    switch (action) {
      case "preview":
        this.previewPage(item);
        break;

      case "delete-api":
        this.deleteItemApi(item);
        break;

      case "delete-form":
        this.deleteItemForm(item);
        break;

      case "move-api":
        this.moveItemApi(item);
        break;

      case "toggle-external-start-page":
        this.toggleExternalStartPage(item);
        break;

      case "disable-external-start-page":
        this.disableExternalStartPage(item);
        break;

      case "preview-external-start-page":
        this.previewExternalStartPage(item);
        break;

      default:
        this.link(item);
    }
  }

  link(element) {
    var $link = element.find("> a");
    location.href = $link.attr("href");
  }

  previewPage(element) {
    var $link = element.find("> a");
    window.open($link.attr("href"));
  }

  deleteItemApi(element) {
    var $link = element.find("> a");
    new DialogApiRequest($link.attr("href"), {
      activator: $link,
      closeOnClickSelector: "button.govuk-button",
      closeText: this.config.view.text.dialogs.button_close,
      onLoad: function (dialog) {
        // Find and correct (make work!) any method:delete links
        dialog.$node.find("[data-method=delete]").on("click", function (e) {
          e.preventDefault();
          post(this.dataset.url, { _method: "delete" });
        });
      },
    });
  }

  deleteItemForm(element) {
    var $link = element.find("> a");
    new DialogForm($link.attr("href"), {
      activator: $link,
      closeText: this.config.view.text.dialogs.button_close,
      autoOpen: true,
      remote: false,
    });
  }

  moveItemApi(element) {
    var $link = element.find("> a");
    new DialogForm($link.attr("href"), {
      activator: $link,
      closeText: this.config.view.text.dialogs.button_close,
      autoOpen: true,
      remote: false,
      onLoad: function (dialog) {
        dialog.$node.find("#move_target_uuid").on("change", function (e) {
          // Get the selected option and then update the hidden conditional
          // uuid field
          var selectedOption = $(this).find("option").eq(this.selectedIndex);
          var conditionalUuid = selectedOption.data("conditional-uuid");
          dialog.$node
            .find("#move_target_conditional_uuid")
            .val(conditionalUuid);
        });
      },
    });
  }

  toggleExternalStartPage(element) {
    var $link = element.find("> a");
    new DialogForm($link.attr("href"), {
      activator: $link,
      closeText: this.config.view.text.dialogs.button_close,
      autoOpen: true,
      remote: true,
      onError: function (data, dialog) {
        var responseHtml = $.parseHTML(data.responseText);
        var $newHtml = $(responseHtml[0]).html();
        dialog.$node.html($newHtml);
        dialog.refresh();
      },
      onSuccess: function () {
        window.location.reload();
      },
    });
  }

  disableExternalStartPage(element) {
    var $link = element.find("> a");
    post($link.attr("href"), { _method: "delete" });
  }

  previewExternalStartPage(element) {
    var $link = element.find("> a");
    new DialogForm($link.attr("href"), {
      activator: $link,
      closeText: this.config.view.text.dialogs.button_close,
      autoOpen: true,
      remote: true,
    });
  }
}
module.exports = PageMenu;
