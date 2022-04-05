require("./setup");

describe("ContentMenu", function() {

  const ContentMenu = require("../app/javascript/src/components/menus/content_menu");
  const COMPONENT_CLASSNAME = "ContentMenu";
  const CONTAINER_ID = "activated-content-menu-test-container-id";
  const CONTAINER_CLASSNAME = "activated-content-menu-test-classname and-another-activated-menu-classname";
  const ACTIVATOR_CLASSNAME = "activated-content-menu-activator-test-classname";
  const ACTIVATOR_TEXT = "activated content menu activator";
  const MENU_ID = "activated-content-menu-test-menu-id";
  const TEST_SELECTION_EVENT_NAME = "ContentMenuTestSelectionEventName";
  var content;

  /* Function to fake a generic content good enough
   * only for testing purpose.
   **/
  function FakeContentClass() {
    var $node = $("<div></div>")
    $node.addClass("Content FakeContent");
    $(document.body).append($node);

    this.$node = $node;
    this.editable = { fake: "editable", content: "object" }
    this.data = {
      validation: {
        something: true
      }
    }
  }

  before(function() {
    // jQuery is present in document because the
    // components use it so we can use it here.

    var $ul = $(`<ul>
                   <li data-action="remove"><span>Remove</span></li>
                   <li data-action="detonate"><span>Detonate</span></li>
                 </ul>`);

    content = new FakeContentClass();

    $(document.body).append($ul);
    $ul.attr("id", MENU_ID);
    content.menu = new ContentMenu (content, $ul, {
      activator_classname: ACTIVATOR_CLASSNAME,
      activator_text: ACTIVATOR_TEXT,

      container_id: CONTAINER_ID,
      container_classname: CONTAINER_CLASSNAME,
      selection_event: TEST_SELECTION_EVENT_NAME
    });
  });

  // ensure menu is closed before each test.
  beforeEach(function() { 
    content.menu.close();
  });


  after(function() {
    content.menu.activator.$node.remove();
    content.menu.container.$node.remove();
    content.menu.$node.remove();
    content.menu = null;

    content.$node.remove();
    content = null;
  });

  describe("ContentMenu", function() {
    it("should have the basic HTML in place", function() {
      expect($("#" + MENU_ID).length).to.equal(1);
    });

    it("should have the component class name present", function() {
      expect($("#" + MENU_ID).parent().hasClass(COMPONENT_CLASSNAME)).to.be.true;
    });

    it("should make the $node public", function() {
      expect(content.menu.$node).to.exist;
      expect(content.menu.$node.length).to.equal(1);
    });

    it("should make the content public", function() {
      expect(content.menu.component).to.exist;
      expect(content.menu.component.$node.length).to.equal(1);
    });

    it("should make the activator public", function() {
      expect(content.menu.activator).to.exist;
    });

    it("should make the container public", function() {
      expect(content.menu.container).to.exist;
    });

    it("should make the instance available as data on the $node", function() {
      expect(content.menu.$node.data("instance")).to.exist;
      expect(content.menu.$node.data("instance")).to.equal(content.menu);
    });

    it("should be able to get menu config", function() {
      expect(content.menu.config).to.exist;
      expect(content.menu.config.activator_text).to.exist;
      expect(content.menu.config.activator_text).to.equal(ACTIVATOR_TEXT);
    });

    it("should not be able set menu config", function() {
      content.menu.config = {
        activator_text: "nope",
      };
      expect(content.menu.config.activator_text).to.equal(ACTIVATOR_TEXT);
    });

    it("should be able to get menu position", function() {
      expect(content.menu.position).to.exist;
      expect(content.menu.position.my).to.exist;
      expect(content.menu.position.my).to.equal("left top");
      expect(content.menu.position.at).to.exist;
      expect(content.menu.position.at).to.equal("left top");
      expect(content.menu.position.of).to.exist;
    });

    it("should not be able set menu position", function() {
      content.menu.position = {
        my: "bottom right",
      };
      expect(content.menu.position.my).to.equal("left top");
    });

    it("should be able to get menu state", function() {
      expect(content.menu.state).to.exist;
      expect(content.menu.state.open).to.exist;
    });

    it("should not be able set menu state", function() {
      content.menu.state = {
        open: true,
      };
      expect(content.menu.state.open).to.be.false;
    });

    it("should open the menu by the open() method", function() {
      expect(content.menu.container.$node.get(0).style.display).to.equal("none");
      content.menu.open();
      expect(content.menu.container.$node.get(0).style.display).to.equal("");
    });

    it("should set the state.open to true when open() is activated", function() {
      expect(content.menu.state.open).to.be.false;
      content.menu.open();
      expect(content.menu.state.open).to.be.true;
    });

    it("should add the class 'active' to the activator on open()", function() {
      expect(content.menu.state.open).to.be.false;
      expect(content.menu.activator.$node.hasClass("active")).to.be.false;

      content.menu.open();
      expect(content.menu.activator.$node.hasClass("active")).to.be.true;
    });

    /* TODO: Test is on hold because we cannot use jsDom
     * for testing position of elements
     **/
    it("should set the position values passed in open()");

    it("should close the menu by the close() method", function() {
      content.menu.open();
      expect(content.menu.container.$node.get(0).style.display).to.equal("");

      content.menu.close();
      expect(content.menu.container.$node.get(0).style.display).to.equal("none");
    });

    it("should set the state.open to false when close() is activated", function() {
      content.menu.open();
      expect(content.menu.state.open).to.be.true;

      content.menu.close();
      expect(content.menu.state.open).to.be.false;
    });

    it("should remove the class 'active' from the activator on close()", function() {
      content.menu.open();
      expect(content.menu.activator.$node.hasClass("active")).to.be.true;

      content.menu.close();
      expect(content.menu.activator.$node.hasClass("active")).to.be.false;
    });

    /* TODO: Test is on hold because we cannot use jsDom
     * for testing position of elements
     */
    it("should reset the position values on close()");

    /* TODO: Test is on hold because we cannot use jsDom
     * for testing mouse events
     **/
    it("should close the menu on mouseout (not sure if can test)");
  });

  describe("Actions", function() {
    it("should activate the detected action method on item selection", function() {
      var $target = content.menu.$node.find("li[data-action=remove]");
      var originalMethod = content.menu.remove;
      var value = 1;

      content.menu.remove = function() {
        value += 1;
      }
      // Check initial value
      expect(value).to.equal(1);

      // Select and check again
      $target.click();
      expect(value).to.equal(2);

      // Reset to original method
      content.menu.remove = originalMethod;
    });

    it("should trigger ContentMenuSelectionRemove event on remove()", function() {
      var value = 1;
      var $target;

      $(document).on("ContentMenuSelectionRemove", function() {
        value += 1;
      });

      expect(value).to.equal(1);

      $target = content.menu.$node.find("li[data-action=remove]");
      expect($target.length).to.equal(1);

      $target.click();
      expect(value).to.equal(2);
    });

    it("should trigger a selection event label on item selection", function() {
      var value = 1;
      var $target;

      $(document).on(TEST_SELECTION_EVENT_NAME, function() {
        value += 1;
      });

      expect(value).to.equal(1);

      $target = content.menu.$node.find("li:first");
      expect($target.length).to.equal(1);

      $target.click();
      expect(value).to.equal(2);
    });
  });

  describe("ActivatedMenuContainer", function() {
    it("should apply the config.container_id to $node", function() {
      expect(content.menu.container.$node.attr("id")).to.equal(CONTAINER_ID);
    });

    it("should apply the config.container_classname to $node", function() {
      var classes = CONTAINER_CLASSNAME.split(" ");
      for(var i=0; i<classes.length; ++i) {
        expect(content.menu.container.$node.hasClass(classes[i])).to.be.true;
      }
    });

    it("should add the Container to the DOM", function() {
      var $node = $("#" + CONTAINER_ID);
      expect($node).to.exist;
      expect($node.length).to.equal(1);
    });

    it("should wrap the passed menu element", function() {
      expect(content.menu.$node.parent().attr("id")).to.equal(CONTAINER_ID);
    });

    it("should make the menu public", function() {
      expect(content.menu.container.menu).to.exist;
      expect(content.menu.container.menu).to.equal(content.menu);
    });

    it("should make the $node public", function() {
      expect(content.menu.container.$node).to.exist;
      expect(content.menu.container.$node.length).to.equal(1);
    });

    it("should make the instance available as data on the $node", function() {
      expect(content.menu.container.$node.data("instance")).to.exist;
      expect(content.menu.container.$node.data("instance")).to.equal(content.menu.container);
    });
  });

  describe("ActivatedMenuActivator (passed)", function() {
    it("should create an activator", function() {
      expect(content.menu.activator).to.exist;
      expect(content.menu.activator.$node).to.exist;
      expect(content.menu.activator.$node.length).to.equal(1);
    });

    it("should make the $node public", function() {
      expect(content.menu.activator.$node).to.exist;
      expect(content.menu.activator.$node.length).to.equal(1);
    });

    it("should make the menu public", function() {
      expect(content.menu.activator.menu).to.exist;
      expect(content.menu.activator.menu).to.equal(content.menu);
    });

    it("should make the instance available as data on the $node", function() {
      expect(content.menu.activator.$node.data("instance")).to.exist;
      expect(content.menu.activator.$node.data("instance")).to.equal(content.menu.activator);
    });

    it("should use config.activator_text for any created activator", function() {
      expect(content.menu.config).to.exist;
      expect(content.menu.config.activator_text).to.exist;
      expect(content.menu.config.activator_text).to.equal(ACTIVATOR_TEXT);
      expect(content.menu.activator.$node.text()).to.equal(ACTIVATOR_TEXT);
    });

    it("should apply config.activator_classname to any created activator", function() {
      expect(content.menu.activator).to.exist;
      expect(content.menu.activator.$node).to.exist;
      expect(content.menu.activator.$node.length).to.equal(1);
      expect(content.menu.activator.$node.hasClass(ACTIVATOR_CLASSNAME)).to.be.true;
    });

    it("should open the menu when activator is clicked", function() {
      expect(content.menu.container.$node.get(0).style.display).to.equal("none");

      content.menu.activator.$node.click();
      expect(content.menu.container.$node.get(0).style.display).to.equal("");
    });
  });
});
