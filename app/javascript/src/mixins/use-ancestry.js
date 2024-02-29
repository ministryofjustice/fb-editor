/**
 * Allows us to setup parent child relationships between controllers
 * Needs to be declared on both the parent and child controllers.
 *
 * The parent controller must have a static `children` property set to the
 * child controller name (kebab cased)
 *
 * The child controller must have a static `ancestor` property set to the
 * child controller name (kebab cased)
 *
 * Controllers now have access to the following methods:
 * addChild()
 * removeCHild()
 * childControllers()
 * ancestorController()
 *
 * Example
 * -------
 * #list-controller.js
 * export default class extends Controller {
 *   static children = 'list-item'
 *
 *   connect() {
 *    useAncestry(this)
 *   }
 * }
 *
 * #list-item-controller.js
 * export default class extends Controller {
 *   static ancestor = 'list'
 *
 *   connect() {
 *    useAncestry(this)
 *   }
 * }
 * */
import { namespaceCamelize } from "../utilities/string-helpers";

export const useAncestry = (controller) => {
  const hasAncestor = () => {
    return controller.constructor.ancestor !== undefined;
  };
  const hasChildren = () => {
    return controller.constructor.children !== undefined;
  };
  const ancestorElement = () => {
    return controller.element.closest(
      `[data-controller*="${ancestorIdentifier()}"]`,
    );
  };

  const hasAncestorController = () => {
    return controller[ancestorControllerKey()] !== undefined;
  };

  const childControllers = () => {
    return controller[childControllersKey()];
  };

  const ancestorControllerKey = () => {
    return `${ancestorName()}Controller`;
  };

  const childControllersKey = () => {
    return `${childName()}Controllers`;
  };

  const siblingControllersKey = () => {
    return `${namespaceCamelize(controller.identifier)}Controllers`;
  };

  const ancestorIdentifier = () => {
    if (controller.constructor.ancestor) {
      return controller.constructor.ancestor;
    } else {
      throw new Error(
        `Missing ancestor property for "${controller.identifier}" controller`,
      );
    }
  };

  const childIdentifier = () => {
    if (controller.constructor.children) {
      return controller.constructor.children;
    } else {
      throw new Error(
        `Missing children property for "${controller.identifier}" controller`,
      );
    }
  };

  const ancestorName = () => {
    return namespaceCamelize(ancestorIdentifier());
  };

  const childName = () => {
    return namespaceCamelize(childIdentifier());
  };

  const connectAncestor = () => {
    if (!hasAncestor()) return;

    if (ancestorElement()) {
      controller[ancestorControllerKey()] =
        controller.application.getControllerForElementAndIdentifier(
          ancestorElement(),
          ancestorIdentifier(),
        );
    }
    if (hasAncestorController()) {
      controller[ancestorControllerKey()]?.addChild(controller);
    }
  };

  Object.assign(controller, {
    addChild(childController) {
      controller[childControllersKey()] = [
        ...(childControllers() || []),
        childController,
      ];
    },

    removeChild(childController) {
      const index = childControllers().indexOf(childController);

      if (index > -1) {
        childControllers().splice(index, 1);
      }
    },
  });

  connectAncestor();
};
