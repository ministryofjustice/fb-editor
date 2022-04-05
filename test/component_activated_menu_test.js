require("./setup");

describe("ActivatedMenu", function() {

  const ActivatedMenu = require("../app/javascript/src/components/menus/activated_menu");
  const COMPONENT_CLASSNAME = "ActivatedMenu";
  const CONTAINER_ID = "activated-menu-test-container-id";
  const CONTAINER_CLASSNAME = "activated-menu-test-classname and-another-activated-menu-classname";
  const ACTIVATOR_CLASSNAME = "activated-menu-activator-test-classname";
  const ACTIVATOR_ID = "activated-menu-test-activator-id";
  const ACTIVATOR_TEXT = "activated menu activator";
  const MENU_ID = "activated-menu-test-menu-id";
  const TEST_SELECTION_ELEMENT_ID = "component-activated-menu-test-selection-event-element";
  const TEST_SELECTION_EVENT_NAME = "ActivatedMenuTestSelectionEventName";
  var menu;

  before(function() {
    // jQuery is present in document because the
    // components use it so we can use it here.

    var $ul = $(`<ul>
                   <li>
                     <span>Item 1a</span>
                     <ul>
                       <li><button id="steven" href="#action1">Item 1b</button></li>
                       <li><a href="#action2">Item 2b</a></li>
                       <li><a href="#action3">Item 3b</a></li>
                     </ul>
                   </li>
                   <li><a href="#action4">Item 2a</a></li>
                   <li><a href="#action5">Item 3a</a></li>
                 </ul>`);

    var $button = $("<button></button>");
    $button.attr("id", ACTIVATOR_ID);
    $button.addClass(ACTIVATOR_CLASSNAME);
    $(document.body).append($ul);
    $(document.body).append($button);

    $ul.attr("id", MENU_ID);
    menu = new ActivatedMenu ($ul, {
      activator: $button,
      activator_classname: ACTIVATOR_CLASSNAME,
      container_id: CONTAINER_ID,
      container_classname: CONTAINER_CLASSNAME,
      activator_text: ACTIVATOR_TEXT,
      preventDefault: true,
      selection_event: TEST_SELECTION_EVENT_NAME
    });
  });

  beforeEach(function() {
    menu.close();
  });

  after(function() {
    menu.$node.remove();
    menu.activator.$node.remove();
    menu.container.$node.remove();
    menu = null;
  });

  describe("ActivatedMenu", function() {
    it("should have the basic HTML in place", function() {
      expect($("#" + MENU_ID).length).to.equal(1);
    });

    it("should have the component class name present", function() {
      expect($("#" + MENU_ID).hasClass(COMPONENT_CLASSNAME)).to.be.true;
    });

    it("should make the $node public", function() {
      expect(menu.$node).to.exist;
      expect(menu.$node.length).to.equal(1);
    });

    it("should make the activator public", function() {
      expect(menu.activator).to.exist;
    });

    it("should make the container public", function() {
      expect(menu.container).to.exist;
    });

    it("should make the instance available as data on the $node", function() {
      expect(menu.$node.data("instance")).to.exist;
      expect(menu.$node.data("instance")).to.equal(menu);
    });

    it("should expose private field config via a getter", function() {
      expect(menu.config).to.exist;
      expect(menu.config.preventDefault).to.exist;
      expect(menu.config.activator_text).to.equal(ACTIVATOR_TEXT);
    });

    it("should not be able to set private config", function() {
      menu.config = {
        activator_text: "nope",
      };
      expect(menu.config.activator_text).to.equal(ACTIVATOR_TEXT);
    });

    it("should expose private field position via a getter", function() {
      expect(menu.position).to.exist;
      expect(menu.position.my).to.exist;
      expect(menu.position.my).to.equal("left top");
      expect(menu.position.at).to.exist;
      expect(menu.position.at).to.equal("left top");
      expect(menu.position.of).to.exist;
    });

    it("should not be able set private position", function() {
      menu.position = {
        my: "bottom right",
      };
      expect(menu.position.my).to.equal("left top");
    });

    it("should expose private field state via a getter", function() {
      expect(menu.state).to.exist;
      expect(menu.state.open).to.exist;
      expect(menu.state.open).to.be.false;
    });

    it("should not be able set private state", function() {
      menu.state = {
        open: true,
      };
      expect(menu.state.open).to.be.false;
    });

    it("should open the menu by the open() method", function() {
      expect(menu.container.$node.get(0).style.display).to.equal("none");

      menu.open();
      expect(menu.container.$node.get(0).style.display).to.equal("");
    });

    it("should set the state.open to true when open() is activated", function() {
      expect(menu.state.open).to.be.false;

      menu.open();
      expect(menu.state.open).to.be.true;
    });

    it("should add the class 'active' to the activator on open()", function() {
      expect(menu.state.open).to.be.false;
      menu.open();
      expect(menu.activator.$node.hasClass("active")).to.be.true;
    });

    /* TODO: Test is on hold because we cannot use jsDom
     * for testing position of elements
     **/
    it("should set the position values passed in open()");

    it("should close the menu by the close() method", function() {
      menu.open();
      expect(menu.container.$node.get(0).style.display).to.equal("");

      menu.close();
      expect(menu.container.$node.get(0).style.display).to.equal("none");
    });

    it("should set the state.open to false when close() is activated", function() {
      menu.open();
      expect(menu.state.open).to.be.true;

      menu.close();
      expect(menu.state.open).to.be.false;
    });

    it("should place focus on the activator on close()", function() {
      menu.open();
      expect(menu.activator.$node.hasClass("active")).to.be.true;

      menu.close();
      expect(menu.activator.$node.hasClass("active")).to.be.true;
      expect(document.activeElement).to.eql(menu.activator.$node[0]);
    });

    /* TODO: Test is on hold because we cannot use jsDom
     * for testing position of elements
     */
    it("should reset the position values on close()");

    /* TODO: Test is on hold because we cannot use jsDom
     * for testing mouse events
     **/
    it("should close the menu on mouseout (not sure if can test)");

    it("should activate the config.selection_event on menu item selection", function() {
      var value = 1;
      $(document).on(TEST_SELECTION_EVENT_NAME, function() {
        value++;
      });

      expect(value).to.equal(1);

      menu.$node.find("li > :first-child").eq(0).click();
      expect(value).to.equal(2);
    });
  });

  describe("ActivatedMenuContainer", function() {
    it("should apply the config.container_id to $node", function() {
      expect(menu.container.$node.attr("id")).to.equal(CONTAINER_ID);
    });

    it("should apply the config.container_classname to $node", function() {
      var classes = CONTAINER_CLASSNAME.split(" ");
      for(var i=0; i<classes.length; ++i) {
        expect(menu.container.$node.hasClass(classes[i])).to.be.true;
      }
    });

    it("should add the Container to the DOM", function() {
      var $node = $("#" + CONTAINER_ID);
      expect($node).to.exist;
      expect($node.length).to.equal(1);
    });

    it("should wrap the original menu element", function() {
      expect(menu.$node.parent().attr("id")).to.equal(CONTAINER_ID);
    });

    it("should make the menu public", function() {
      expect(menu.container.menu).to.exist;
      expect(menu.container.menu).to.equal(menu);
    });

    it("should make the $node public", function() {
      expect(menu.container.$node).to.exist;
      expect(menu.container.$node.length).to.equal(1);
    });

    it("should make the instance available as data on the $node", function() {
      expect(menu.container.$node.data("instance")).to.exist;
      expect(menu.container.$node.data("instance")).to.equal(menu.container);
    });
  });

  describe("ActivatedMenuActivator (passed)", function() {
    it("should use the passed activator when present in config", function() {
      expect(menu.activator).to.exist;
      expect(menu.activator.$node).to.exist;
      expect(menu.activator.$node.length).to.equal(1);
      expect(menu.activator.$node.get(0)).to.equal($("." + ACTIVATOR_CLASSNAME).get(0));
    });

    it("should make the $node public", function() {
      expect(menu.activator.$node).to.exist;
      expect(menu.activator.$node.length).to.equal(1);
    });

    it("should make the menu public", function() {
      expect(menu.activator.menu).to.exist;
      expect(menu.activator.menu).to.equal(menu);
    });

    it("should make the instance available as data on the $node", function() {
      expect(menu.activator.$node.data("instance")).to.exist;
      expect(menu.activator.$node.data("instance")).to.equal(menu.activator);
    });

    it("should open the menu when activator is clicked", function() {
      expect(menu.container.$node.get(0).style.display).to.equal("none");

      menu.activator.$node.click();
      expect(menu.container.$node.get(0).style.display).to.equal("");
    });
  });

  describe("ActivatedMenuActivator (created)", function() {
    const ACTIVATOR_CLASSNAME = "activated-menu-created-activator-classname";
    const ACTIVATOR_TEXT = "activated menu text here";
    var menu_creating_activator;

    before(function() {
      var $ul = $(`<ul>
                     <li>
                       <span>Item 1a</span>
                       <ul>
                         <li><button id="steven" href="#action1">Item 1b</button></li>
                         <li><a href="#action2">Item 2b</a></li>
                       </ul>
                     </li>
                     <li><a href="#action4">Item 2a</a></li>
                   </ul>`);

      $(document.body).append($ul);

      menu_creating_activator = new ActivatedMenu ($ul, {
        activator_classname: ACTIVATOR_CLASSNAME,
        activator_text: ACTIVATOR_TEXT
      });
    });

    after(function() {
      menu_creating_activator.$node.remove();
      menu_creating_activator.activator.$node.remove();
      menu_creating_activator.container.$node.remove();
      menu_creating_activator = null;
    });

    it("should create an activator when none is passed in config", function() {
      expect(menu_creating_activator.config.activator).to.not.exist;
      expect(menu_creating_activator.activator).to.exist;
      expect(menu_creating_activator.activator.$node).to.exist;
      expect(menu_creating_activator.activator.$node.length).to.equal(1);
    });

    it("should use config.activator_text for any created activator", function() {
      expect(menu_creating_activator.config.activator_text).to.exist;
      expect(typeof menu_creating_activator.config.activator_text).to.equal("string");
      expect(menu_creating_activator.config.activator_text).to.equal(ACTIVATOR_TEXT);
      expect(menu_creating_activator.activator.$node.text()).to.equal(ACTIVATOR_TEXT);
    });

    it("should apply config.activator_classname to any created activator", function() {
      var classes = ACTIVATOR_CLASSNAME.split(" ");

      expect(menu_creating_activator.config.activator_classname).to.exist;
      expect(typeof menu_creating_activator.config.activator_classname).to.equal("string");
      expect(menu_creating_activator.config.activator_classname).to.equal(ACTIVATOR_CLASSNAME);

      for(var i=0; i<classes.length; ++i) {
        expect(menu_creating_activator.activator.$node.hasClass(classes[i])).to.be.true;
      }
    });
  });

});
