require('../../setup');

describe("Expander", function() {

  const helpers = require("./helpers.js");
  const c = helpers.constants;
  const CONTAINER_ID = "expander-for-testing-component";

  describe("Component", function() {
    var created;
    before(function() {
      helpers.setupView(CONTAINER_ID);
      created = helpers.createExpander(CONTAINER_ID);
    });

    after(function() {
      helpers.teardownView(CONTAINER_ID);
      created = {};
    });


    /* BASIC MARKKUP (such as helper.js file setup)
     * --------------------------------------------
     * e.g.
     * <div class="content">
     *   <h2>Title</h2>
     *   <p>Lorem ipsum dolor sit amet</p>
     *   <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
     *   <p>Lorem ipsum dolor sit amet consecteteur</p>
     * </div>
     **/
    it("should have the basic HTML in place", function() {
      var $container = $('#' + CONTAINER_ID);
      var $content = $container.find("." + c.CLASSNAME_CONTENT);

      expect($content.length).to.equal(1);
      expect($content.find("h2").length).equal(1);
      expect($content.find("p").length).equal(3);
    });

    it("should have the expander class name present", function() {
      var $container = $('#' + CONTAINER_ID);
      var $content = $container.find("." + c.CLASSNAME_CONTENT);
      expect($content.find("div").get(0).className).to.equal(c.CLASSNAME_COMPONENT);
    });

    it("should enhance with a button", function() {
      var $button = $('#' + CONTAINER_ID).find('button');

      expect($button.length).to.equal(1);
      expect($button.get(0).className).to.equal(c.CLASSNAME_ACTIVATOR);
    });

    it("should add an ID to the $node and aria-controls to the button", function() {
      var $content = $('#' + CONTAINER_ID);
      var $button = $content.find('button');

      expect($content.find("." + c.CLASSNAME_COMPONENT).attr('id')).to.include('Expander');
      expect($button.attr('aria-controls')).to.include('Expander');
      expect($content.find("." + c.CLASSNAME_COMPONENT).attr('id')).to.equal($button.attr('aria-controls'));
    });
  });


  /* Definition list (<DL>)
   * ----------------------
   * e.g.
   * <dl>
   *   <dt>Title</dt>
   *   <dd>
   *     <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
   *     <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
   *   </dd>
   * </dl>
   **/
  describe("Component from <dl>", function() {
    const COMPONENT_MARKUP_DL = "expander-for-testing-component-markup-dl";
    var createdFromList;

    before(function() {
      // Add some new HTML
      var $content = $(`<dl id="` + COMPONENT_MARKUP_DL + `">
                          <dt>Title</dt>
                          <dd class="` + c.CLASSNAME_CONTENT + `">
                            <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
                            <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
                          </dd>
                        </dl>`);

     $(document.body).append($content);

      // Create the expander with button specified as activator_source
      createdFromList = helpers.createExpander(COMPONENT_MARKUP_DL, {
                          activator_source: $content.find("dt"), // Need to force it to avoid the testing default
                          wrap_content: false
                        });
    });

    after(function() {
      helpers.teardownView(COMPONENT_MARKUP_DL);
    });

    it("should have the HTML in place", function() {
      var $container = $('#' + COMPONENT_MARKUP_DL);
      expect($container.length).to.equal(1);
      expect($container.find("dt").length).equal(1);
      expect($container.find("dd").length).equal(1);
      expect($container.find("p").length).equal(2);
    });

    it("should have enhanced the dd to be an Expander", function() {
      var $dd = $('#' + COMPONENT_MARKUP_DL + " dd");
      expect($dd.length).to.equal(1);
      expect($dd.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

    it("should have enhanced the dt to be an Activator", function() {
      var $dt = $('#' + COMPONENT_MARKUP_DL + " dt");
      expect($dt.length).to.equal(1);
      expect($dt.find("button").hasClass(c.CLASSNAME_ACTIVATOR)).to.be.true;
    });
  });


  /* Disclosure (<DETAILS><SUMMARY>)
   * -------------------------------
   * e.g.
   * <details>
   *   <summary>Title</summary>
   *   <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
   *   <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
   * </details>
   **/
  describe("Component from <details>", function() {
    const COMPONENT_MARKUP_DISCLOSURE = "expander-for-testing-component-markup-details";
    var createdFromDisclosure;

    before(function() {
      // Add some new HTML
      var $content = $(`<div id="` + COMPONENT_MARKUP_DISCLOSURE + `">
                          <details class="` + c.CLASSNAME_CONTENT + `">
                            <summary>Title</summary>
                            <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
                            <p>Lorem ipsum dolor sit amet consecteteur adipiscing elit</p>
                          </details>
                        </div>`);

     $(document.body).append($content);

      // Create the expander with button specified as activator_source
      createdFromDisclosure = helpers.createExpander(COMPONENT_MARKUP_DISCLOSURE);
    });

    after(function() {
      helpers.teardownView(COMPONENT_MARKUP_DISCLOSURE);
    });

    it("should have the HTML in place", function() {
      var $container = $('#' + COMPONENT_MARKUP_DISCLOSURE);
      expect($container.length).to.equal(1);
      expect($container.find("details").length).equal(1);
      expect($container.find("p").length).equal(2);
    });

    it("should have enhanced the details to be an Expander", function() {
      var $details = $('#' + COMPONENT_MARKUP_DISCLOSURE + " details");
      expect($details.length).to.equal(1);
      expect($details.hasClass(c.CLASSNAME_COMPONENT)).to.be.true;
    });

    it("should have enhanced the summary to be an Activator", function() {
      var $summary = $('#' + COMPONENT_MARKUP_DISCLOSURE + " summary");
      expect($summary.length).to.equal(1);
      expect($summary.hasClass(c.CLASSNAME_ACTIVATOR)).to.be.true;
    });
  });

});
