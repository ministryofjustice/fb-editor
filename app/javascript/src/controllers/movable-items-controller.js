import { Controller } from "@hotwired/stimulus";
import { useControllerName } from "../mixins/use-controller-name";
import { useAncestry } from "../mixins/use-ancestry";

export default class extends Controller {
  static targets = ["movableItem"];
  static children = "movable-item";

  connect() {
    useControllerName(this);
    useAncestry(this);
  }

  // updateButtonVisibilty() {
  //   this.movableItemTargets.forEach((element, index) => {
  //     index == 0
  //       ? element.movableItemController.upButtonTarget.setAttribute(
  //           "hidden",
  //           "",
  //         )
  //       : element.movableItemController.upButtonTarget.removeAttribute(
  //           "hidden",
  //         );
  //     index == this.movableItemTargets.length - 1
  //       ? element.movableItemController.downButtonTarget.setAttribute(
  //           "hidden",
  //           "",
  //         )
  //       : element.movableItemController.downButtonTarget.removeAttribute(
  //           "hidden",
  //         );
  //   });
  // }
}
