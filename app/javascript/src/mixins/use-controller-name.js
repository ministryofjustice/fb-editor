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
  Object.defineProperty(controller, "controllerName", {
    get() {
      return namespaceCamelize(controller.identifier) + "Controller";
    },
  });

  controller.element[`${controller.controllerName}`] = controller;
};
