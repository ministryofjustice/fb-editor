require("../setup");


describe("BranchQuestion", function() {

  const helpers = require("./branch_helpers.js");
  const c = helpers.constants;
  const COMPONENT_ID = "branch-for-testing-branch-condition";

  var branch;
  var $question;

  before(function() {
    var created = helpers.createBranch(COMPONENT_ID);

    $question = $(c.SELECTOR_PRE_BRANCH_QUESTION, created.$node);
    branch = created.branch;

    $(document.body).append(created.$node);
  });

  after(function() {
    branch.$node.remove();
  });


  it("should have the basic HTML in place", function() {
    // Just adding something basic here but it might change.
    expect($question.length).to.equal(1);
    expect($question.get(0).nodeName.toLowerCase()).to.equal("div");
  });

  it("should have the component class name present", function() {
    expect($question.hasClass("BranchQuestion")).to.be.true;
  });

  it("should make the instance available as data on the $node", function() {
    var instance = $question.data("instance");
    expect(instance).to.exist;
    expect(instance.$node.length).to.equal(1);
  });

  it("should make the $node public", function() {
    var question = $question.data("instance");
    expect(question.$node).to.exist;
    expect(question.$node.length).to.equal(1);
    expect(question.$node.get(0)).to.equal($question.get(0));
  });

  describe("clearErrorState", function() {
    const SELECTOR_ERROR_MESSAGE = ".error-message";
    var $condition, question;

    beforeEach(function() {
      question = $question.data("instance");
      question._$error = $("<p class=\"error-message\">Some error</p>");
      $question.append(question._$error);
      $condition = $(c.SELECTOR_BRANCH_CONDITION);
    });

    afterEach(function() {
      $question.find(SELECTOR_ERROR_MESSAGE).remove();
      question._$error = null;
    });

    it("should remove the inserted error node", function() {
      expect($question.find(SELECTOR_ERROR_MESSAGE).length).to.equal(1);
      question.clearErrorState();
      expect($question.find(SELECTOR_ERROR_MESSAGE).length).to.equal(0);
    });

    it("should nullify the private reference to error node", function() {
      expect(question._$error).to.exist;
      question.clearErrorState();
      expect(question._$error).to.not.exist;
    });

    it("should remove the error class from condition node", function() {
      expect($condition.find(SELECTOR_ERROR_MESSAGE).length).to.equal(1);
      question.clearErrorState();
      expect($condition.find(SELECTOR_ERROR_MESSAGE).length).to.equal(0);
    });

    it("should remove template injected error message identified in config", function() {
      // Insert a test error message
      $question.append("<p class=\"" + c.CLASSNAME_BRANCH_ERROR_MESSAGE + "\">" + c.TEXT_ERROR_MESSAGE  + "</p>");

      // Check it's there
      expect($question.find("." + c.CLASSNAME_BRANCH_ERROR_MESSAGE).length).to.equal(1);

      // Call the method and recheck for existence
      question.clearErrorState();
      expect($question.find("." + c.CLASSNAME_BRANCH_ERROR_MESSAGE).length).to.equal(0);
    });

    it("should remove template injected error class identified in config", function() {
      // First add some classes
      $question.addClass(c.CLASSNAME_ERROR_1);
      $question.find("select").addClass(c.CLASSNAME_ERROR_2);

      // Then check they exist
      expect($question.hasClass(c.CLASSNAME_ERROR_1)).to.be.true;
      expect($question.find("select").hasClass(c.CLASSNAME_ERROR_2)).to.be.true;
    });
  });

  describe("Error", function() {
    var $condition, question;

    before(function() {
      question = $question.data("instance");
      $condition = $(c.SELECTOR_BRANCH_CONDITION);
    });

    afterEach(function() {
      $condition.removeClass("error");
      question._$error.remove();
      question._$error = null;
    });

    it("should make (public but indicated as) private reference to error", function() {
      expect(question._$error).to.not.exist;

      question.error();
      expect(question._$error).to.exist;
      expect(question._$error.length).to.equal(1);
    });

    it("should create an error based on passed type", function() {
      question.error("unsupported");
      expect(question._$error.text()).to.equal(c.TEXT_ERROR_MESSAGE);
    });

    it("should show a default message when no type is passed", function() {
      question.error();
      expect(question._$error.text()).to.equal("An error occured");
    });

    it("should add a class to the condition node", function() {
      expect($condition.hasClass("error")).to.be.false;
      question.error();
      expect($condition.hasClass("error")).to.be.true;
    });

    it("should add an error node to question", function() {
      expect($question.find(".error-message").length).to.equal(0);
      question.error();
      expect($question.find(".error-message").length).to.equal(1);
    });
  });

  describe("Change", function() {
    it("should exist as a method on question", function() {
      var instance = $question.data("instance");
      expect(instance.change).to.exist;
      expect(typeof instance.change).to.equal("function");
    });

    it("should call BranchQuestion.clearErrorState", function() {
      var instance = $question.data("instance");
      var check = 1;
      instance.clearErrorState = function() {
        check += 1;
      }

      instance.change(); // Doesn't matter what we pass in.
      expect(check).to.equal(2);

      // Reset to original
      instance.clearErrorState = instance.constructor.prototype.clearErrorState;
    });

    it("should call BranchCondition.clear", function() {
      var instance = $question.data("instance");
      var check = 1;
      instance.condition.clear = function() {
        check += 1;
      }

      instance.change(); // Doean't matter what we pass in (again).
      expect(check).to.equal(2);

      // Reset to original
      instance.condition.clear = instance.condition.constructor.prototype.clear;
    });

    it("should call condition.update on selection of supported question", function() {
      var condition = $(c.SELECTOR_BRANCH_CONDITION).data("instance");
      var question = $question.data("instance");
      var check = 1;
      condition.update = function() {
        check += 1;
      }

      // First a little setup test
      expect(condition).to.exist;
      expect(condition.update).to.exist;
      expect(question).to.exist;
      expect(question.change).to.exist;
      expect(check).to.equal(1);

      // Then the main event
      question.change(true);
      expect(check).to.equal(2);

      // Reset the condition method so we don't spoil other tests
      condition.update = condition.constructor.prototype.update;
      question.change(true); // This should no longer affect check
      expect(check).to.equal(2);
    });

    it("should show an error on selection of unsupported question", function() {
      var condition = $(c.SELECTOR_BRANCH_CONDITION).data("instance");
      var question = $question.data("instance");

      expect(condition).to.exist;
      expect(question).to.exist;
      expect($(".error-message").length).to.equal(0);
      question.change(false);
      expect($(".error-message").length).to.equal(1);

      // Remove to clean up
      $(".error-message").remove();
      expect($(".error-message").length).to.equal(0);
    });
  });

});
