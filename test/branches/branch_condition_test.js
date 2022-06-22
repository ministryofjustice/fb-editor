require("../setup");


describe("BranchCondition", function() {

  const helpers = require("./branch_helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "branch-for-testing-branch-condition";

  var branch;
  var $condition;

  before(function() {
    var created = helpers.createBranch(COMPONENT_ID);

    $condition = $(c.SELECTOR_PRE_BRANCH_CONDITION, created.$node);
    branch = created.branch;

    $(document.body).append(created.$node);
  });

  after(function() {
    branch.$node.remove();
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

  // TODO: Add test when BranchCondition is in own file
  it("should create a BranchCondition instance");

  it("should make the instance available as data on the $node", function() {
    var instance = $condition.data("instance");
    expect(instance).to.exist;
    expect(instance.$node.length).to.equal(1);
  });

  it("should make the remover public", function() {
    var instance = $condition.data("instance");
    expect(instance.remover).to.exist;
    expect(instance.remover.$node.length).to.equal(1);
  });

  it("should make the question public", function() {
    var instance = $condition.data("instance");
    expect(instance.question).to.exist;
    expect(instance.question.$node.length).to.equal(1);
  });

  it("should make the answer public", function() {
    var instance = $condition.data("instance");
    expect(instance.answer).to.exist;
    expect(instance.answer.$node.length).to.equal(1);
  });


  describe("update", function() {
    var get;

    beforeEach(function() {
      // Hijack $.get to fake a response
      get = $.get;
      $.get = function(urlNotNeeded, response) {
        response(`<div class="answer">
          <select><option>is</option></select>
          <select><option>This answer value</option></select>
        </div>`);
      }
    });

    afterEach(function() {
       // First remove the hardcoded .answer element.
       $condition.find(c.SELECTOR_PRE_BRANCH_ANSWER).remove();

       // Reset to original function
       $.get = get;
    });

    it("should add html for answer on selected question", function() {
      var condition = $condition.data("instance");

      $condition.find(c.SELECTOR_PRE_BRANCH_ANSWER).remove(); // First remove the hardcoded .answer element.

      expect($condition).to.exist;
      expect($condition.length).to.equal(1);
      expect($condition.find(c.SELECTOR_PRE_BRANCH_ANSWER).length).to.equal(0);

      expect(condition).to.exist;
      condition.update("component-id-here");
      expect($condition.find(c.SELECTOR_PRE_BRANCH_ANSWER).length).to.equal(1);
    });
  });


  describe("clear", function() {
    it("should remove html for answer", function() {
      var condition = $condition.data("instance");
      expect(condition).to.exist;
      expect($condition).to.exist;
      expect($condition.length).to.equal(1);

      // Fake an existing Answer element.
      condition.answer = {
        $node: $("<div class=\"answer BranchAnswer\"></div>")
      }

      $condition.append(condition.answer.$node);
      expect($condition.find(c.SELECTOR_PRE_BRANCH_ANSWER).length).to.equal(1);

      condition.clear();
      expect($condition.find(c.SELECTOR_PRE_BRANCH_ANSWER).length).to.equal(0);
    });
  });
});
