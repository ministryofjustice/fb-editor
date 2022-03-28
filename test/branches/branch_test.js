require("../setup");

describe("Branch", function () {

  const helpers = require("./branch_helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "branch-for-testing-branch";

  var branch;


  before(function() {
    var created = helpers.createBranch(COMPONENT_ID);
    $(document.body).append(created.$node);
    branch = created.branch;
  });

  after(function() {
    branch.$node.remove();
  });


  describe("Component", function() {
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
      expect(branch.view.text.branches.condition_add).to.equal(c.TEXT_CONDITION_ADD);
    });

    it("should make the destination public", function() {
      expect(branch.destination).to.exist;
    });

    it("should make the condition injector public", function() {
      expect(branch.conditionInjector).to.exist;
    });

  });
});
