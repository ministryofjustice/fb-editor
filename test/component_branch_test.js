require("./setup");

describe("Component", function () {

  const Branch = require('../app/javascript/src/component_branch.js');
  const COMPONENT_ID = "testing-branch";
  const BRANCH_CONDITION_SELECTOR = ".condition";
  const BRANCH_DESTINATION_SELECTOR = ".destination";
  var branch;

  before(function() {
    var $html = $(`<div class="branch" id="testing-branch">
      <p>Branch ...</p>
      <div class="destination">
        <div data-conditional-index="1">
          <label for="branch_next">Go to</label>
          <select id="branch_next">
            <option value="">--- Select a destination page ---</option>
            <option value="618a037b">Service name goes here</option>
            <option value="088dcdbe">Question</option>
            <option value="4d707045">Title</option>
          </select>
        </div>
      </div>
      <div class="condition">
        <div class="question" data-expression-index="0">
          <label for="branch_1">If</label>
          <select id="branch_1">
            <option value="">--Select a question--</option>
            <option value="a24f492b">Question</option>
          </select>
        </div>
      </div>
    </div>`);

    $(document.body).append($html);
    branch = new Branch($html, {
      condition_selector: BRANCH_CONDITION_SELECTOR,
      destination_selector: BRANCH_DESTINATION_SELECTOR,
      view: {
        text: "Something, something, something... darkside."
      }
    });
  });

  describe("Branch", function() {
    it("should have the basic HTML in place", function() {
      expect($("#" + COMPONENT_ID).length).to.equal(1);
    });

    it("should have the component class name present", function() {
      expect($("#" + COMPONENT_ID).hasClass("Branch")).to.be.true;
    });

    it("should make the $node public", function() {
      expect(branch.$node).to.exist;
      expect(branch.$node.length).to.equal(1);
      expect(branch.$node.attr("id")).to.equal(COMPONENT_ID);
    });

    it("should make the instance available as data on the $node", function() {
      var instance = $("#" + COMPONENT_ID).data("instance");
      expect(instance.$node).to.exist;
      expect(instance.$node.length).to.equal(1);
      expect(instance.$node.attr("id")).to.equal(COMPONENT_ID);
    });

    it("should make the view public", function() {
      expect(branch.view).to.exist;
      expect(branch.view.text).to.equal("Something, something, something... darkside.");
    });

    it("should make the destination public", function() {
      expect(branch.destination).to.exist;
    });

    it("should make the condition public", function() {
      expect(branch.condition).to.exist;
    });

    it("should make (public but indicated as) private reference to config", function() {
      expect(branch._config).to.exist;
      expect(branch._config.condition_selector).to.equal(BRANCH_CONDITION_SELECTOR);
    });
  });

  describe("BranchDestination", function() {
    var $destination;

    beforeEach(function() {
      $destination = $(BRANCH_DESTINATION_SELECTOR);
    });

    it("should have the basic HTML in place", function() {
      // TODO: Not sure if this is useful at this point but complexity
      // may develop with a greater need for increased checks over time.
      expect($destination.length).to.equal(1);
      expect($destination.get(0).nodeName.toLowerCase()).to.equal("div");
    });

    it("should have the component class name present", function() {
      expect($destination.hasClass("BranchDestination")).to.be.true;
    });

    it("should make the instance available as data on the $node", function() {
      var instance = $destination.data("instance");
      expect(instance).to.exist;
      expect(branch.destination).to.equal(instance);
    });

    it("should make the $node public", function() {
      var instance = $destination.data("instance");
      expect(instance.$node).to.exist;
      expect(instance.$node.length).to.equal(1);
      expect(instance.$node.get(0)).to.equal($destination.get(0));
    });

    it("should make (public but indicated as) private reference to config", function() {
      var instance = $destination.data("instance");
      expect(instance._config).to.exist;
      expect(instance._config.destination_selector).to.equal(BRANCH_DESTINATION_SELECTOR);
    });
  });

  describe("BranchCondition", function() {
    var $condition;

    beforeEach(function() {
      $condition = $(BRANCH_CONDITION_SELECTOR);
    });

    it("should have the basic HTML in place", function() {
      // Just adding something basic here but it might change.
      expect($condition.length).to.equal(1);
      expect($condition.get(0).nodeName.toLowerCase()).to.equal("div");
    });

    it("should have the component class name present", function() {
      expect($condition.hasClass("BranchCondition")).to.be.true;
    });

    it("should make the $node public", function() {
      var instance = $condition.data("instance");
      expect(instance.$node).to.exist;
      expect(instance.$node.length).to.equal(1);
      expect(instance.$node.get(0)).to.equal($condition.get(0));
    });

    it("should make (public but indicated as) private reference to config", function() {
      var instance = $condition.data("instance");
      expect(instance._config).to.exist;
      expect(instance._config.condition_selector).to.equal(BRANCH_CONDITION_SELECTOR);
    });
  });
});
