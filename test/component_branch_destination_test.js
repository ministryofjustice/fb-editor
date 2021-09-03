require("./setup");

describe("BranchDestination", function () {

  const BranchDestination = require('../app/javascript/src/component_branch_destination.js');
  const BRANCH_DESTINATION_SELECTOR = ".destination";
  const ERROR_MESSAGE = "This is an error message";
  const ERROR_MESSAGE_CLASSNAME = "some-message"
  const ERROR_CLASSNAME_1 = "error";
  const ERROR_CLASSNAME_2 = "form-group-error";
  var test;

  function createBranchDestination() {
    var html = `<div class="branch">
        <div class="destination">
          <div class="form-group">
            <label for="branch_next">Go to</label>
            <select id="branch_next">
              <option value="">--- Select a destination page ---</option>
              <option value="618a037b">Service name goes here</option>
              <option value="088dcdbe">Question</option>
              <option value="4d707045">Title</option>
            </select>
          </div>
        </div>
      </div>`;

    var $node = $(html).find(BRANCH_DESTINATION_SELECTOR);
    var instance = new BranchDestination($node, {
      css_classes_error: ERROR_CLASSNAME_1 + " " + ERROR_CLASSNAME_2,
      selector_error_messsage: ("." + ERROR_MESSAGE_CLASSNAME),
      view: {
        text: {
          message: ERROR_MESSAGE
        }
      }
    });

    return {
      html: html,
      $node: $node,
      instance: instance
    }
  }

  before(function() {
    test = createBranchDestination();
    $(document.body).append(test.$node);
  });


  describe("Component", function() {

    it("should have the basic HTML in place", function() {
      // Possibly don't need this as it's a bit basic but
      // trying to be consistent with other component tests.
      expect(test.$node.length).to.equal(1);
      expect(test.$node.get(0).nodeName.toLowerCase()).to.equal("div");
    });

    it("should have the component class name present", function() {
      expect(test.$node.hasClass("BranchDestination")).to.be.true;
    });

    it("should make the instance available as data on the $node", function() {
      var instance = test.$node.data("instance");
      expect(instance).to.exist;
      expect(test.instance).to.equal(instance);
    });

    it("should make the $node public", function() {
      expect(test.instance.$node).to.exist;
      expect(test.instance.$node.length).to.equal(1);
      expect(test.instance.$node.get(0)).to.equal(test.$node.get(0));
    });

    it("should make (public but indicated as) private reference to config", function() {
      expect(test.instance._config).to.exist;
      expect(test.instance._config.view).to.exist;
      expect(test.instance._config.view.text).to.exist;
      expect(test.instance._config.view.text.message).to.exist;
      expect(test.instance._config.view.text.message).to.equal(ERROR_MESSAGE);
    });

    describe("clearErrorState", function() {
      it("should exist as a public function", function() {
        expect(test.instance.clearErrorState).to.exist;
        expect(typeof test.instance.clearErrorState).to.equal("function");
      });

      it("should clear any injected error messages", function() {
        test.$node.append("<p class=\"" + ERROR_MESSAGE_CLASSNAME + "\">" + ERROR_MESSAGE + "</p>");

        // First check error is there.
        expect(test.$node.find("." + ERROR_MESSAGE_CLASSNAME).length).to.equal(1);

        // Now activate function and check again.
        test.instance.clearErrorState();
        expect(test.$node.find("." + ERROR_MESSAGE_CLASSNAME).length).to.equal(0);
      });

      it("should clear any added class names for error styles", function() {
         test.$node.find("select").addClass(ERROR_CLASSNAME_1);
         test.$node.find(".form-group").addClass(ERROR_CLASSNAME_2);

         // First check we can find elements by the added classnames.
         expect(test.$node.find("." + ERROR_CLASSNAME_1).length).to.equal(1);
         expect(test.$node.find("." + ERROR_CLASSNAME_2).length).to.equal(1);

         // Now activate the function and check again.
         test.instance.clearErrorState();
         expect(test.$node.find("." + ERROR_CLASSNAME_1).length).to.equal(0);
         expect(test.$node.find("." + ERROR_CLASSNAME_2).length).to.equal(0);
      });
    });
  });
});
