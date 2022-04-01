require("../setup");


describe("BranchConditionRemover", function() {

  const helpers = require("./branch_helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "branch-for-testing-branch-condition";

  var branch;
  var $remover;

  before(function() {
    var created = helpers.createBranch(COMPONENT_ID);

    $remover = $(c.SELECTOR_PRE_BRANCH_CONDITION_REMOVER, created.$node);
    branch = created.branch;

    $(document.body).append(created.$node);
  });

  after(function() {
    branch.$node.remove();
  });


  it("should have basic HTML in place", function() {
    expect($remover.length).to.equal(1);
    expect($remover.get(0).nodeName.toLowerCase()).to.equal("button");
  });

  it("should have the component class name present", function() {
    expect($remover.hasClass("BranchConditionRemover")).to.be.true;
  });

  it("should make the instance available as data on the $node", function() {
    var remover = $remover.data("instance");
    expect(remover).to.exist;
    expect(remover.$node.length).to.equal(1);
  });

  it("should make the $node public", function() {
    var remover = $remover.data("instance");
    expect(remover.$node).to.exist;
    expect(remover.$node.length).to.equal(1);
    expect(remover.$node.get(0)).to.equal($remover.get(0));
  });

  it("should make a public reference to connected condition", function() {
    var remover = $remover.data("instance");
    expect(remover.condition).to.exist;
    expect(remover.condition.$node.length).to.equal(1);
  });


  describe("confirm", function() {
    it("should run the activate function if no dialog exists in config", function() {
      var check = 1;
      var remover = $remover.data("instance");
      var originalActivateMethod = remover.activate;
      remover.activate = function() {
        check += 1;
      }

      expect(check).to.equal(1);
      remover.confirm();
      expect(check).to.equal(2);

      remover.activate = originalActivateMethod;
    });

    it("should open a dialog if one exists in config", function() {
      var check = 1;
      var confirmTest = helpers.createBranch("confirmTest", {
        dialog_delete: {
          open: function() {
            ++check;
          }
        }
      });

      var $confirmTestCondition = $(c.SELECTOR_BRANCH_CONDITION, confirmTest.$node);
      var branchConditionConfirmTestRemover = $confirmTestCondition.data("instance").remover;

      expect(check).to.equal(1);

      branchConditionConfirmTestRemover.confirm();
      expect(check).to.equal(2);

      // clean up
      confirmTest.$node.remove();
      confirmTest = null;
    });
  });

  describe("activate", function() {
    var check, branch, originalRemoveCondition;

    before(function() {
      var remover = $remover.data("instance");
      branch = remover.condition.branch;
      originalRemoveCondition = branch.removeCondition;
      branch.removeCondition = function() {
        check += 1;
      }
    });

    after(function() {
      branch.removeCondition = originalRemoveCondition;
    });

    it("should call branch.removeCondition() method", function() {
      var remover = $remover.data("instance");
      check = 1;

      // First check value is correct...
      expect(check).to.equal(1);

      // Activate method and check value has increased.
      remover.activate();
      expect(check).to.equal(2);
    });
  });

});
