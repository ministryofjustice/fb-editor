require('../../setup');

describe("Expander", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "expander-for-testing-configurations";

  describe("Configurations", function() {
    var created;
    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createExpander(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });


    /* TEST Configuration: Activator Source
     **/
    describe("When activator is a jQuery element (not a <button>)", function() {
      it("should wrap the activator content with a <button>", function() {
        var $content = $('#' + CONTAINER_ID);

        expect($content.find('h2 > button').length).to.equal(1);
        expect($content.find('h2 > button').first().attr('id')).to.eql(created.expander.$activator.attr('id'));
        expect($content.find('h2 > button').first().text()).to.equal('Title');
      });
    });


    describe("When activator is a jQuery <button> element", function() {
      const CONTAINER_ID_WITH_BUTTON_ACTIVATOR = "expander-for-testing-configurations-button-activator";
      const BUTTON_COMPONENT_ID = "button-expander-test-id";
      var createdWithButton;

      before(function() {
        var $button = $("<button>Title</button>");

        $button.attr('id', BUTTON_COMPONENT_ID);

        // Add some new HTML
        createdWithButton = helpers.setupView(CONTAINER_ID_WITH_BUTTON_ACTIVATOR);

        // Add the button to the content
        $("#" + CONTAINER_ID_WITH_BUTTON_ACTIVATOR + " ." + c.CLASSNAME_CONTENT).append($button);

        // Create the expander with button specified as activator_source
        createdWithButton = helpers.createExpander(CONTAINER_ID_WITH_BUTTON_ACTIVATOR, {
                              activator_source: $button,
                            });
      });

      after(function() {
        $('#' + BUTTON_COMPONENT_ID).remove();
        helpers.teardownView(CONTAINER_ID_WITH_BUTTON_ACTIVATOR);
      });

      it("should use the activator button as the toggle", function() {
        var $activator = $('.' + c.CLASSNAME_ACTIVATOR, createdWithButton.$node);

        expect($activator.length).to.equal(1);
        expect($activator.get(0).tagName.toLowerCase()).to.equal("button");
        expect($activator.attr('aria-expanded')).to.equal('false');
        expect($activator.attr('aria-controls')).to.include('Expander_');
      });
    });


    describe("When activator is a string", function() {
      const CONTAINER_ID_WITH_STRING_ACTIVATOR = "expander-for-testing-configurations-string-activator";
      const TEXT_FOR_STRING_ACTIVATOR = "some text that will become an activator";
      var createdWithStringActivator;

      before(function() {
        // Add some new HTML
        helpers.setupView(CONTAINER_ID_WITH_STRING_ACTIVATOR);

        // Create the expander with button specified as activator_source
        createdWithStringActivator = helpers.createExpander(CONTAINER_ID_WITH_STRING_ACTIVATOR, {
                              activator_source: TEXT_FOR_STRING_ACTIVATOR,
                            });
      });

      after(function() {
        helpers.teardownView(CONTAINER_ID_WITH_STRING_ACTIVATOR);
      });

      it('should generate a button and add it as previous sibling to the Expander', function() {
        var $button = createdWithStringActivator.$node.find('.' + c.CLASSNAME_ACTIVATOR);

        expect(createdWithStringActivator.$node.length).to.equal(1);
        expect($button.length).to.equal(1);
        expect(createdWithStringActivator.expander.$node.prev().get(0)).to.equal($button.get(0));
      });
    });


    /* TEST Configuration: Wrap content
     **/
    describe("When wrap_content is true", function() {
      it("should wrap contents with a div", function() {
        var $container = $("#" + CONTAINER_ID);
        var $content = $container.find(" ." + c.CLASSNAME_CONTENT);
        expect($content.children().length).to.equal(2);
        expect($content.find("div").length).to.equal(1);
        expect($content.find("div").hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
        expect($content.children().last().get(0).className).to.equal(c.CLASSNAME_COMPONENT);
        expect($content.children().last().attr("id")).to.include("Expander_");
        expect($content.children().last().find("p").length).to.equal(3);
      });
    });


    describe("When wrap_content is false", function() {
      const CONTAINER_ID_WITHOUT_WRAP = "expander-for-testing-configurations-wrap-content-false";
      var createdWithoutWrap;

      before(function() {
        // Add some new HTML
        var $content = $(`<div id="` + CONTAINER_ID_WITHOUT_WRAP + `">
                        <dl>
                          <dt>Title</dt>
                          <dd class="` + c.CLASSNAME_CONTENT + `">
                            <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
                            <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
                          </dd>
                        </dl>
                      </div>`);

       $(document.body).append($content);

        // Create the expander with button specified as activator_source
        createdWithoutWrap = helpers.createExpander(CONTAINER_ID_WITHOUT_WRAP, {
                               activator_source: $content.find("dt"), // Need to force it to avoid the testing default
                               wrap_content: false
                             });
      });

      after(function() {
        helpers.teardownView(CONTAINER_ID_WITHOUT_WRAP);
      });

      it('does not wrap content with a div', function() {
        var $container = $('#' + CONTAINER_ID_WITHOUT_WRAP);
        var $content = $container.find('dd');
        expect($container.find('div').length).to.equal(0);
        expect($content.length).to.equal(1);
        expect($content.parent().get(0).tagName.toLowerCase()).to.equal("dl");
        expect($content.get(0)).to.equal(createdWithoutWrap.expander.$node.get(0));
        expect($content.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
        expect($content.attr('id')).to.include('Expander_');
      });
    });


    /* TEST Configuration: Auto open
     **/
    describe("When auto_open is false", function() {
      it("should be closed", function() {
        var $content = $('#' + CONTAINER_ID);
        var $expander = $content.find("." + c.CLASSNAME_COMPONENT);
        var instance = $expander.data('instance');

        expect($expander.get(0).style.display).to.equal('none');
        expect($content.find('button').first().attr('aria-expanded')).to.equal('false');
        expect(instance.isOpen()).to.be.false;
      })
    });


    describe("When auto_open is true", function() {
      const CONTAINER_ID_WITH_AUTO_OPEN = "expander-for-testing-configurations-with_auto_open";
      var createdWithAutoOpen;

      before(function() {
        helpers.setupView(CONTAINER_ID_WITH_AUTO_OPEN);
        createdWithAutoOpen = helpers.createExpander(CONTAINER_ID_WITH_AUTO_OPEN, {
          auto_open: true
        });
      });

      after(function() {
        helpers.teardownView(CONTAINER_ID_WITH_AUTO_OPEN);
      });

      it("should be open", function() {
        var $container = $('#' + CONTAINER_ID_WITH_AUTO_OPEN);
        var $content = $container.find('.' + c.CLASSNAME_CONTENT);

        expect(createdWithAutoOpen.expander.$node.get(0).style.display).to.equal('');
        expect($content.find('button').first().attr('aria-expanded')).to.equal('true');
        expect(createdWithAutoOpen.expander.isOpen()).to.be.true;
      })
    });
  });
});
