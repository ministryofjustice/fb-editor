require("../setup");


describe("BranchRemover", function() {

  const helpers = require("./branch_helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "branch-for-testing-branch-condition";

  var branch;
  var $remover;

  before(function() {
    var created = helpers.createBranch(COMPONENT_ID);
    branch = created.branch;

    $remover = $(c.SELECTOR_PRE_BRANCH_REMOVER, created.$node);

    $(document.body).append(created.$node);
  });

  after(function() {
    branch.$node.remove();
  });


  it("should have the basic HTML in place", function() {
    expect($remover.length).to.equal(1);
    expect($remover.get(0).nodeName.toLowerCase()).to.equal("a");
    expect($remover.text()).to.equal(c.TEXT_BRANCH_REMOVE);
  });

  it("should have the component class name present", function() {
    expect($remover.hasClass("BranchRemover")).to.be.true;
  });

  it("should make the $node public", function() {
    var instance = $remover.data("instance");
    expect(instance.$node).to.exist;
    expect(instance.$node.length).to.equal(1);
    expect(instance.$node.get(0)).to.equal($remover.get(0));
  });

  it("should make the instance available as data on the $node", function() {
    var instance = $remover.data("instance");
    expect(instance).to.exist;
    expect(instance.$node.length).to.equal(1);
  });

  it("should call the branch.destroy method", function() {
    var check = 1;
    branch.destroy = function() {
      check += 1;
    }

    expect(check).to.equal(1);

    $remover.click();
    expect(check).to.equal(2);

    branch.destroy = branch.constructor.prototype.destroy;
  });

  /* TODO: Do we still need this test or should it be updated.
   * Note: remover.confirm() is no longer a public function so can no longer test like this.
   *
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
      var confirmTestBranch = createBranch("confirmTestBranch", {
        dialog_delete: {
          open: function() {
            ++check;
          }
        }
      });

      expect(check).to.equal(1);

      confirmTestBranch.branch.remover.confirm();
      expect(check).to.equal(2);

      // clean up
      confirmTestBranch.$node.remove();
      confirmTestBranch = null;
    });
  });
  */

  describe("activate", function() {
    var check, branch, originalDestroy;

    before(function() {
      var remover = $remover.data("instance");
      branch = remover.branch;
      originalDestroy = branch.destroy;
      branch.destroy = function() {
        check += 1;
      }
    });

    after(function() {
      branch.destroy = originalDestroy;
    });

    it("should call branch.destroy() method", function() {
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
