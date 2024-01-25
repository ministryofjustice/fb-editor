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
}
