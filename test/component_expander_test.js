require('./setup');

describe("Expander", function() {

  const Expander = require('../app/javascript/src/component_expander');
  const EXPANDER_ID = 'component-expander-test-id';
  const EXPANDER_CLASSNAME = 'Expander';
  const CONTAINER_CLASSNAME = 'Expander__container';
  const ACTIVATOR_CLASSNAME = 'Expander__activator';
  var $expander;

  before(function() {
    var $expander = $(`<div>
        <h2>Title</h2>
        <p>Lorem ipsum dolor sit amet</p>
        <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
        <p>Lorem ipsum dolor sit amet consecteteur</p>
      </div>`); 

    $expander.attr('id', EXPANDER_ID);
    $(document.body).append($expander);

    expander = new Expander($expander, {
      activator: $expander.find('> h2').first(),
    });
  });

  afterEach(function(){
    $('#' + EXPANDER_ID).data('instance').close();
  })

  after(function() {
    $('#' + EXPANDER_ID).remove();
  });

  describe("HTML", function() {
    it("should have the basic HTML in place", function() {
      expect($('#' + EXPANDER_ID).length).to.equal(1);
    });

    it("should have the expander class name present", function() { 
      expect($('#' + EXPANDER_ID).get(0).className).to.equal(EXPANDER_CLASSNAME);
    });

    it("should add the container class", function() {
      var $container = $('#' + EXPANDER_ID).find('.' + CONTAINER_CLASSNAME );

      expect($container.length).to.equal(1);
    });

    it("should enhance with a button", function() {
      var $button = $('#' + EXPANDER_ID).find('button');

      expect($button.length).to.equal(1);
      expect($button.get(0).className).to.equal(ACTIVATOR_CLASSNAME);
    })

    it("should add an ID to the container and aria-controls to the button", function() {
      var $container = $('#' + EXPANDER_ID).find('.' + CONTAINER_CLASSNAME );
      var $button = $('#' + EXPANDER_ID).find('button');

      expect($container.attr('id')).to.include('Expander');
      expect($button.attr('aria-controls')).to.include('Expander');
      expect($container.attr('id')).to.equal($button.attr('aria-controls'));
    });
  })

  describe("Properties", function() {
    it("should make the instance available as data on the $node", function() {
      expect(expander.$node).to.exist;
      expect(expander.$node.length).to.equal(1);
      expect(expander.$node.data("instance")).to.eql(expander);
    });

    it("should make the $node public", function() {
      var expander = $("#" + EXPANDER_ID).data("instance");

      expect(expander.$node).to.exist;
      expect(expander.$node.length).to.equal(1);
      expect(expander.$node.attr("id")).to.equal(EXPANDER_ID);
    });

    it("should make the $activator public", function() {
      var expander = $("#" + EXPANDER_ID).data("instance");

      expect(expander.$activator).to.exist;
      expect(expander.$activator.length).to.equal(1);
      expect(expander.$activator.get(0).className).to.equal(ACTIVATOR_CLASSNAME);
    });


  });

  describe("Open", function() {
    beforeEach(function() {
      var expander = $("#" + EXPANDER_ID).data("instance");
      expander.open();
    });

    it("should set the state to open", function() {
      expect(expander.isOpen()).to.be.true;
    })

    it("should set the aria-expanded attribute", function() {
      expect(expander.$node.find('button').attr('aria-expanded')).to.equal("true");
    });

    it("should show the content container", function() {
      expect(expander.$node.find('.'+CONTAINER_CLASSNAME).get(0).style.display).to.equal(""); 
    })
  });

  describe("Close", function() {
    beforeEach(function() {
      var expander = $("#" + EXPANDER_ID).data("instance");
      expander.open();
      expander.close();
    });

    it("should set the state to open", function() {
      expect(expander.isOpen()).to.be.false;
    })

    it("should set the aria-expanded attribute", function() {
      expect(expander.$node.find('button').attr('aria-expanded')).to.equal("false");
    });

    it("should hide the content container", function() {
      expect(expander.$node.find('.'+CONTAINER_CLASSNAME).get(0).style.display).to.equal("none"); 
    })
  });
  
  describe("Toggle", function() {
    it("should toggle the open state", function() {
      var expander = $("#" + EXPANDER_ID).data("instance"); 
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
      var $expander = $('#' + EXPANDER_ID);

      expect($expander.find('h2 > button').length).to.equal(1);
      expect($expander.find('h2 > button').first().attr('id')).to.eql(expander.$activator.attr('id'));
      expect($expander.find('h2 > button').first().text()).to.equal('Title');
    });

  });

  describe("When activator is a jQuery <button> element", function() {
    const BUTTON_EXPANDER_ID = "button-expander-test-id";

    before(function() { 
      var $buttonExpander = $(`<div>
        <button>Title</Button>
        <p>Lorem ipsum dolor sit amet</p>
        <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
      </div>`);

      $buttonExpander.attr('id', BUTTON_EXPANDER_ID );
      $(document.body).append($buttonExpander);
      
      buttonExpander = new Expander($buttonExpander, {
        activator: $buttonExpander.find('> button').first(),
      });
    })

    it("should use the activator button as the toggle", function() {
      var $expander = $('#' + BUTTON_EXPANDER_ID);

      expect($expander.find('button').length).to.equal(1);
      expect($expander.find('button').first().get(0).className).to.equal(ACTIVATOR_CLASSNAME);
      expect($expander.find('button').first().attr('aria-expanded')).to.equal('false');
      expect($expander.find('button').first().attr('aria-controls')).to.include('Expander_');
    })

    after(function() {
      $('#'+BUTTON_EXPANDER_ID).remove();
    });
  });

  describe("When activator is a string", function() {
    const STRING_EXPANDER_ID = "string-expander-test-id";

    before(function() { 
      var $stringExpander = $(`<div>
        <p>Lorem ipsum dolor sit amet</p>
        <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
      </div>`); 

      $stringExpander.attr('id', STRING_EXPANDER_ID );
      $(document.body).append($stringExpander);
      
      stringExpander = new Expander($stringExpander, {
        activator: 'Show More',
      });
    });

    it('should generate a button and add it as the first child of the component', function() {
      var $expander = $('#'+STRING_EXPANDER_ID);

      expect($expander.find('button').length).to.equal(1);
      expect($expander.children().first().prop('nodeName')).to.equal('BUTTON');
      expect($expander.find('button').first().get(0).className).to.equal(ACTIVATOR_CLASSNAME);
      expect($expander.find('button').first().attr('aria-expanded')).to.equal('false');
      expect($expander.find('button').first().attr('aria-controls')).to.include('Expander_');
    });

    after(function() {
      $('#'+STRING_EXPANDER_ID).remove();
    });
  });

  describe("When wrap_content is true", function() {
    it("should wrap contents with a div", function() { 
      var $expander = $('#' + EXPANDER_ID);

      expect($expander.children().length).to.equal(2);
      expect($expander.children().last().get(0).className).to.equal(CONTAINER_CLASSNAME);
      expect($expander.children().last().attr('id')).to.include('Expander_');
      expect($expander.children().last().children().length).to.equal(3);
    });
  });

  describe("When wrap_content is false", function() {
    const UNWRAPPED_EXPANDER_ID = "unwrapped-expander-test-id";

    before(function() { 
      var $dlExpander = $(`<dl>
        <dt>Title</dt>
        <dd>
          <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
          <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
        </dd>
      </dl>`);

      $dlExpander.attr('id', UNWRAPPED_EXPANDER_ID );
      $(document.body).append($dlExpander);
      
      dlExpander = new Expander($dlExpander, {
        activator: $dlExpander.find('dt').first(),
        wrap_content: false,
      });
    });

    it('does not wrap content with a div', function() {
      var $expander = $('#' + UNWRAPPED_EXPANDER_ID);

      expect($expander.find('div').length).to.equal(0);
      expect($expander.find('dd').first().get(0).className).to.equal(CONTAINER_CLASSNAME);
      expect($expander.find('dd').first().attr('id')).to.include('Expander_');
    });

    after(function() {
      $('#' + UNWRAPPED_EXPANDER_ID).remove();
    });
  });
  
  describe("When auto_open is false", function() {
    it("should be closed", function() {
      var $expander = $('#' + EXPANDER_ID);
      var instance = $expander.data('instance');

      expect($expander.find('.' + CONTAINER_CLASSNAME ).get(0).style.display).to.equal('none');
      expect($expander.find('button').first().attr('aria-expanded')).to.equal('false');
      expect(instance.isOpen()).to.be.false;
    })
  });

  describe("When auto_open is true", function() {
    before(function() {
      $expander = $('#'+EXPANDER_ID);
      expander = new Expander($expander, {
        activator: $expander.find('> h2').first(),
        auto_open: true,
      });
    });

    it("should be open", function() {
      var $expander = $('#' + EXPANDER_ID);
      var instance = $expander.data('instance');

      expect($expander.find('.' + CONTAINER_CLASSNAME ).get(0).style.display).to.equal('');
      expect($expander.find('button').first().attr('aria-expanded')).to.equal('true');
      expect(instance.isOpen()).to.be.true;
    })
  });
});
