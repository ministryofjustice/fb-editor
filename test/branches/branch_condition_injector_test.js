require("../setup");


describe("BranchConditionInjector", function() {

  const helpers = require("./branch_helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "branch-for-testing-branch-condition";

  var branch;
  var $injector;

  before(function() {
    var created = helpers.createBranch(COMPONENT_ID);

    $injector = $(c.SELECTOR_PRE_BRANCH_CONDITION_INJECTOR, created.$node);
    branch = created.branch;

    $(document.body).append(created.$node);
  });

  after(function() {
    branch.$node.remove();
  });


  it("should have the basic HTML in place", function() {
    expect($injector).to.exist;
    expect($injector.length).to.equal(1);
    expect($injector.text()).to.equal(c.TEXT_CONDITION_ADD);
  });

  it("should have the component class name present", function() {
    expect($injector.length).to.equal(1);
    expect($injector.hasClass("BranchConditionInjector")).to.be.true;
  });

  it("should make the $node public", function() {
    expect(branch.conditionInjector).to.exist;
    expect(branch.conditionInjector.$node).to.exist;
    expect(branch.conditionInjector.$node.length).to.equal(1);
  });

  it("should make the instance available as data on the $node", function() {
    expect(branch.conditionInjector).to.exist;
    expect($injector.data("instance")).to.exist;
    expect($injector.data("instance")).to.equal(branch.conditionInjector);
  });

  it("should make the branch public", function() {
    var instance = $injector.data("instance");
    expect(instance.branch).to.exist;
    expect(instance.branch).to.equal(branch);
  });

  it("should add a condition when clicked", function() {
    expect(branch.$node.find(c.SELECTOR_PRE_BRANCH_CONDITION).length).to.equal(1);
    $injector.click();
    expect(branch.$node.find(c.SELECTOR_PRE_BRANCH_CONDITION).length).to.equal(2);
  });
});
