/**
 * In order to facilitate co-ordination between controllers
 * and avoid using the private `getControllerForElementAndIdentifier` method
 * it is useful to add a reference to a controller instance onto the
 * controller's element.
 *
 * This mixin:
 *  - Correctly camelizes a stimulus controller identifier
 *  - Adds a `controllerName` property onto the controller
 *  - Adds a reference to the controller instance onto the element ussing the
 *  controllerName
 **/
import { namespaceCamelize } from "../utilities/string-helpers";
export const useControllerName = (controller) => {
  // turn a stimulus controller name into a camelized string
  // see: https://leastbad.com/stimulus-power-move

  // const camelize = (str) => {
  //   return str
  //     .split("--")
  //     .slice(-1)[0]
  //     .split(/[-_]/)
  //     .map((w) => w.replace(/./, (m) => m.toUpperCase()))
  //     .join("")
  //     .replace(/^\w/, (c) => c.toLowerCase());
  // };

  Object.defineProperty(controller, "controllerName", {
    get() {
      return namespaceCamelize(controller.identifier) + "Controller";
    },
  });

  controller.element[`${controller.controllerName}`] = controller;
};
