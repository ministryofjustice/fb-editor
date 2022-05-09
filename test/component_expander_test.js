require('./setup');

describe("Expander", function() {

  const Expander = require('../app/javascript/src/component_expander');
  const CONTENT_ID = 'component-expander-test-id';
  const EXPANDER_CLASSNAME = 'Expander';
  const ACTIVATOR_CLASSNAME = 'Expander__activator';
  var expander;

  before(function() {
    var $content = $(`<div>
        <h2>Title</h2>
        <p>Lorem ipsum dolor sit amet</p>
        <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
        <p>Lorem ipsum dolor sit amet consecteteur</p>
      </div>`);

    $content.attr('id', CONTENT_ID);
    $(document.body).append($content);

    expander = new Expander($content, {
      activator_source: $content.find('> h2').first(),
    });
  });

  afterEach(function(){
    expander.close();
  })

  after(function() {
    $('#' + CONTENT_ID).remove();
  });

  describe("HTML", function() {
    it("should have the basic HTML in place", function() {
      var $content = $('#' + CONTENT_ID);

      expect($content.length).to.equal(1);
      expect($content.find("h2").length).equal(1);
      expect($content.find("p").length).equal(3);
    });

    it("should have the expander class name present", function() {
      expect($('#' + CONTENT_ID).find("div").get(0).className).to.equal(EXPANDER_CLASSNAME);
    });

    it("should enhance with a button", function() {
      var $button = $('#' + CONTENT_ID).find('button');

      expect($button.length).to.equal(1);
      expect($button.get(0).className).to.equal(ACTIVATOR_CLASSNAME);
    })

    it("should add an ID to the $node and aria-controls to the button", function() {
      var $content = $('#' + CONTENT_ID);
      var $button = $content.find('button');

      expect($content.find("." + EXPANDER_CLASSNAME).attr('id')).to.include('Expander');
      expect($button.attr('aria-controls')).to.include('Expander');
      expect($content.find("." + EXPANDER_CLASSNAME).attr('id')).to.equal($button.attr('aria-controls'));
    });
  })

  describe("Properties", function() {
    it("should make the instance available as data on the $node", function() {
      expect(expander.$node).to.exist;
      expect(expander.$node.length).to.equal(1);
      expect(expander.$node.data("instance")).to.eql(expander);
    });

    it("should make the $node public", function() {
      expect(expander.$node).to.exist;
      expect(expander.$node.length).to.equal(1);
      expect(expander.$node.attr("id")).to.include("Expander");
    });

    it("should make the $activator public", function() {
      expect(expander.$activator).to.exist;
      expect(expander.$activator.length).to.equal(1);
      expect(expander.$activator.get(0).className).to.equal(ACTIVATOR_CLASSNAME);
    });
  });


  describe("Open", function() {
    beforeEach(function() {
      expander.open();
    });

    it("should set the state to open", function() {
      expect(expander.isOpen()).to.be.true;
    })

    it("should set the aria-expanded attribute", function() {
      var $content = $('#' + CONTENT_ID);
      expect($content.find('button').attr('aria-expanded')).to.equal("true");
    });

    it("should show the content container", function() {
      expect(expander.$node.get(0).style.display).to.equal(""); 
    })
  });


  describe("Close", function() {
    beforeEach(function() {
      expander.open();
      expander.close();
    });

    it("should set the state to open", function() {
      expect(expander.isOpen()).to.be.false;
    })

    it("should set the aria-expanded attribute", function() {
      var $content = $('#' + CONTENT_ID);
      expect($content.find('button').attr('aria-expanded')).to.equal("false");
    });

    it("should hide the content container", function() {
      expect(expander.$node.get(0).style.display).to.equal("none"); 
    })
  });


  describe("Toggle", function() {
    it("should toggle the open state", function() {
      expander.open();
      expect(expander.isOpen()).to.be.true;
      expander.toggle();
      expect(expander.isOpen()).to.be.false;
      expander.toggle();
      expect(expander.isOpen()).to.be.true;
    });
  });


  describe("When activator is a jQuery element (not a <button>)", function() {
    it("should wrap the activator content with a <button>", function() {
      var $content = $('#' + CONTENT_ID);

      expect($content.find('h2 > button').length).to.equal(1);
      expect($content.find('h2 > button').first().attr('id')).to.eql(expander.$activator.attr('id'));
      expect($content.find('h2 > button').first().text()).to.equal('Title');
    });
  });


  describe("When activator is a jQuery <button> element", function() {
    const BUTTON_CONTENT_ID = "button-expander-test-id";
    var buttonExpander;

    before(function() { 
      var $content = $(`<div>
        <button>Title</Button>
        <p>Lorem ipsum dolor sit amet</p>
        <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
      </div>`);

      $content.attr('id', BUTTON_CONTENT_ID);
      $(document.body).append($content);
      
      buttonExpander = new Expander($content, {
        activator: $content.find('> button').first(),
      });
    })

    it("should use the activator button as the toggle", function() {
      var $content = $('#' + BUTTON_CONTENT_ID);
      var $activator = $content.find('.' + ACTIVATOR_CLASSNAME);

      expect($activator.length).to.equal(1);
      expect($activator.get(0).tagName.toLowerCase()).to.equal("button");
      expect($activator.attr('aria-expanded')).to.equal('false');
      expect($activator.attr('aria-controls')).to.include('Expander_');
    })

    after(function() {
      $('#'+BUTTON_CONTENT_ID).remove();
    });
  });


  describe("When activator is a string", function() {
    const STRING_CONTENT_ID = "string-expander-test-id";
    var stringExpander;

    before(function() { 
      var $content = $(`<div>
        <p>Lorem ipsum dolor sit amet</p>
        <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
      </div>`); 

      $content.attr('id', STRING_CONTENT_ID );
      $(document.body).append($content);
      
      stringExpander = new Expander($content, {
        activator: 'Show More',
      });
    });

    it('should generate a button and add it as previous sibling to the Expander', function() {
      var $content = $('#' + STRING_CONTENT_ID);
      var $button = $content.find('.' + ACTIVATOR_CLASSNAME);
      var $expander = $content.find('.' + EXPANDER_CLASSNAME);

      expect($content.length).to.equal(1);
      expect($button.length).to.equal(1);
      expect($expander.length).to.equal(1);
      expect($expander.prev().get(0)).to.equal($button.get(0));
    });

    after(function() {
      $('#'+STRING_CONTENT_ID).remove();
    });
  });


  describe("When wrap_content is true", function() {
    it("should wrap contents with a div", function() {
      var $content = $('#' + CONTENT_ID);
      var $wrapper = $content.find('.' + EXPANDER_CLASSNAME);

      expect($content.find("div").length).to.equal(1);
      expect($content.children().length).to.equal(2);
      expect($content.children().last().get(0).className).to.equal(EXPANDER_CLASSNAME);
      expect($content.children().last().attr('id')).to.include('Expander_');
      expect($wrapper.children().length).to.equal(3);
    });
  });


  describe("When wrap_content is false", function() {
    const UNWRAPPED_CONTENT_ID = "unwrapped-expander-test-id";
    var dlExpander;

    before(function() {
      var $content = $(`<dl>
        <dt>Title</dt>
        <dd>
          <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
          <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
        </dd>
      </dl>`);

      $content.attr('id', UNWRAPPED_CONTENT_ID);
      $(document.body).append($content);

      dlExpander = new Expander($content.find("dd"), {
        activator: $content.find('dt').first(),
        wrap_content: false,
      });
    });

    it('does not wrap content with a div', function() {
      var $content = $('#' + UNWRAPPED_CONTENT_ID);
      var $dd = $content.find('dd');
      var $expander = $content.find('.' + EXPANDER_CLASSNAME);

      expect($content.length).to.equal(1);
      expect($content.find('div').length).to.equal(0);
      expect($dd.get(0)).to.equal($expander.get(0));
      expect($dd.hasClass(EXPANDER_CLASSNAME)).to.be.true;
      expect($dd.attr('id')).to.include('Expander_');
    });

    after(function() {
      $('#' + UNWRAPPED_CONTENT_ID).remove();
    });
  });


  describe("When auto_open is false", function() {
    it("should be closed", function() {
      var $content = $('#' + CONTENT_ID);
      var $expander = $content.find("." + EXPANDER_CLASSNAME);
      var instance = $expander.data('instance');

      expect($expander.get(0).style.display).to.equal('none');
      expect($content.find('button').first().attr('aria-expanded')).to.equal('false');
      expect(instance.isOpen()).to.be.false;
    })
  });


  describe("When auto_open is true", function() {
    var auto_open_expander;

    before(function() {
      $content = $('#' + CONTENT_ID);
      auto_open_expander = new Expander($content, {
        activator: $content.find('> h2').first(),
        auto_open: true,
      });
    });

    it("should be open", function() {
      var $content = $('#' + CONTENT_ID);
      var $expander = $content.find("." + EXPANDER_CLASSNAME);
      var instance = $expander.data('instance');

      expect($expander.get(0).style.display).to.equal('');
      expect($content.find('button').first().attr('aria-expanded')).to.equal('true');
      expect(instance.isOpen()).to.be.true;
    })
  });
});
