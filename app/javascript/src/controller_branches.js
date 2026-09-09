/**
 * Branches Controller
 * ----------------------------------------------------
 *
 **/


const DefaultController = require('./controller_default');

class BranchesController extends DefaultController {
  constructor(app) {
    super(app);

    this.$document.on("ConfirmBranchConditionalRemoval", (event) => {
      this.dialogConfirmationDelete.onConfirm = event.detail.action;
      this.dialogConfirmationDelete.open({
        heading: this.text.dialogs.heading_delete_branch,
        content: this.text.dialogs.message_delete_branch,
        confirm: this.text.dialogs.button_delete_branch
      });
    });

    this.$document.on("ConfirmBranchExpressionRemoval", (event) => {
      this.dialogConfirmationDelete.onConfirm = event.detail.action;
      this.dialogConfirmationDelete.open({
        heading: this.text.dialogs.heading_delete_condition,
        content: this.text.dialogs.message_delete_condition,
        confirm: this.text.dialogs.button_delete_condition
      });
    });
  }
}

module.exports = BranchesController;
