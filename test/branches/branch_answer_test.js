require("../setup");

describe("BranchAnswer", function() {

  const helpers = require("./branch_helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "branch-for-testing-branch-condition";

  var branch;
  var $answer, get;

  before(function() {
    var created = helpers.createBranch(COMPONENT_ID);
    branch = created.branch;

    // Hijack $.get to fake a response
    get = $.get;
    $.get = function(urlNotNeeded, response) {
        response(`<div class="answer">
                  <select><option>is</option></select>
                  <select><option>This answer value</option></select>
                </div>`);

        return({
          fail: function(callback) {
            callback({ status: 401 });
          }
        });
      }

    // Remove any Answer that is hardcoded.
    $answer = $(c.SELECTOR_PRE_BRANCH_ANSWER, created.$node).remove();

    // Set the answer node and create a BranchAnswer by calling update() function
    $(c.SELECTOR_BRANCH_CONDITION, created.$node).data("instance").update("asdfdfa");
    $answer = $(c.SELECTOR_PRE_BRANCH_ANSWER, created.$node);

    $(document.body).append(created.$node);
  });

  after(function() {
    branch.$node.remove();
    $answer.remove();
    $.get = get; // Reset to original function
  });


  it("should have the basic HTML in place", function() {
    // Just adding something basic here but it might change.
    expect($answer.length).to.equal(1);
    expect($answer.get(0).nodeName.toLowerCase()).to.equal("div");
  });

  it("should have the component class name present", function() {
    expect($answer.hasClass("BranchAnswer")).to.be.true;
  });

  it("should make the $node public", function() {
    var instance = $answer.data("instance");
    expect(instance.$node).to.exist;
    expect(instance.$node.length).to.equal(1);
    expect(instance.$node.get(0)).to.equal($answer.get(0));
  });

  it("should make the instance available as data on the $node", function() {
    var instance = $answer.data("instance");
    expect(instance).to.exist;
    expect(instance.$node.length).to.equal(1);
  });

});
