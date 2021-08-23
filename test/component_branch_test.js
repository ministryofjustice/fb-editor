require("./setup");

describe("Branch", function () {

  const Branch = require('../app/javascript/src/component_branch.js');
  const COMPONENT_ID = "testing-branch";
  const BRANCH_DESTINATION_SELECTOR = ".destination";
  const BRANCH_CONDITION_SELECTOR = ".condition";
  const BRANCH_QUESTION_SELECTOR = ".question";
  const BRANCH_ANSWER_SELECTOR = ".answer";
  const EXPRESSION_URL = "/not/needed";
  const LABEL_QUESTION_AND = "And";
  const TEXT_ADD_CONDITION = "add condition text";
  const ERROR_MESSAGE = "This is an error message";
  const INDEX_BRANCH = 4;
  var global_test_branch;

  function createBranch(id) {
    var html = `<div class="branch" id="` + id + `">
        <p>Branch ...</p>
        <div class="destination">
          <div class="form-group">
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
          <div class="question">
            <label for="branch_1">If</label>
            <select id="branch_1">
              <option value="">--Select a question--</option>
              <option value="a24f492b" data-supports-branching="true">Supported Question</option>
              <option value="b34f593a" data-supports-branching="false">Unsupported Question</option>
            </select>
          </div>
        </div>
      </div>`;

    var $node = $(html);
    var branch = new Branch($node, {
      branch_index: INDEX_BRANCH,
      selector_condition: BRANCH_CONDITION_SELECTOR,
      selector_destination: BRANCH_DESTINATION_SELECTOR,
      selector_question: BRANCH_QUESTION_SELECTOR,
      expression_url: EXPRESSION_URL,
      question_label: LABEL_QUESTION_AND,
      template_condition: "<div class=\"condition\">dummy</div>",
      view: {
        text: {
          branches: {
            add_condition: TEXT_ADD_CONDITION
          },
          errors: {
            branches: {
              unsupported_question: ERROR_MESSAGE
            }
          }
        }
      }
    });

    return {
      html: html,
      $node: $node,
      branch: branch
    }
  }

  before(function() {
    var created = createBranch(COMPONENT_ID);
    $(document.body).append(created.$node);
    global_test_branch = created.branch;
  });


  describe("Component", function() {
    it("should have the basic HTML in place", function() {
      expect($("#" + COMPONENT_ID).length).to.equal(1);
    });

    it("should have the component class name present", function() {
      expect($("#" + COMPONENT_ID).hasClass("Branch")).to.be.true;
    });

    it("should make the $node public", function() {
      expect(global_test_branch.$node).to.exist;
      expect(global_test_branch.$node.length).to.equal(1);
      expect(global_test_branch.$node.attr("id")).to.equal(COMPONENT_ID);
    });

    it("should make the instance available as data on the $node", function() {
      var instance = $("#" + COMPONENT_ID).data("instance");
      expect(instance.$node).to.exist;
      expect(instance.$node.length).to.equal(1);
      expect(instance.$node.attr("id")).to.equal(COMPONENT_ID);
    });

    it("should make the view public", function() {
      expect(global_test_branch.view).to.exist;
      expect(global_test_branch.view.text.branches.add_condition).to.equal(TEXT_ADD_CONDITION);
    });

    it("should make the destination public", function() {
      expect(global_test_branch.destination).to.exist;
    });

    it("should make the condition injector public", function() {
      expect(global_test_branch.conditionInjector).to.exist;
    });

    it("should make (public but indicated as) private reference to config", function() {
      expect(global_test_branch._config).to.exist;
      expect(global_test_branch._config.selector_condition).to.equal(BRANCH_CONDITION_SELECTOR);
    });

    it("should make (public but indicated as) private reference to index value", function() {
      expect(global_test_branch._index).to.exist;
      expect(global_test_branch._index).to.equal(INDEX_BRANCH);
    });

    it("should make (public but indicated as) private reference to condition counter value", function() {
      expect(global_test_branch._conditionCount).to.exist;
      expect(global_test_branch._conditionCount).to.equal(0);
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
      expect(global_test_branch.destination).to.equal(instance);
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
      expect(instance._config.selector_destination).to.equal(BRANCH_DESTINATION_SELECTOR);
    });
  });

  describe("BranchCondition", function() {
    var $condition;

    before(function() {
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
      expect(instance._config.selector_condition).to.equal(BRANCH_CONDITION_SELECTOR);
    });

    it("should make (public but indicated as) private reference to index value", function() {
      var instance = $condition.data("instance");
      expect(instance._index).to.equal(0);
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
         global_test_branch.$node.find(BRANCH_ANSWER_SELECTOR).remove();
         // Reset to original function
         $.get = get;
      });

      it("should add html for answer on selected question", function() {
        var condition = $condition.data("instance");

        expect($condition).to.exist;
        expect($condition.length).to.equal(1);
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(0);

        expect(condition).to.exist;
        condition.update("component-id-here");
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(1);
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
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(1);

        condition.clear();
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(0);
      });
    });
  });


  describe("BranchConditionInjector", function() {
    var $injector;

    before(function() {
      $injector = global_test_branch.$node.find("button:last");
    });

    it("should have the basic HTML in place", function() {
      expect($injector).to.exist;
      expect($injector.length).to.equal(1);
      expect($injector.text()).to.equal(TEXT_ADD_CONDITION);
    });

    it("should have the component class name present", function() {
      expect($injector.length).to.equal(1);
      expect($injector.hasClass("BranchConditionInjector")).to.be.true;
    });

    it("should make the $node public", function() {
      expect(global_test_branch.conditionInjector).to.exist;
      expect(global_test_branch.conditionInjector.$node).to.exist;
      expect(global_test_branch.conditionInjector.$node.length).to.equal(1);
    });

    it("should make the instance available as data on the $node", function() {
      expect(global_test_branch.conditionInjector).to.exist;
      expect($injector.data("instance")).to.exist;
      expect($injector.data("instance")).to.equal(global_test_branch.conditionInjector);
    });

    it("should make (public but indicated as) private reference to config", function() {
      var instance = $injector.data("instance");
      expect(instance._config).to.exist;
      expect(instance._config.view).to.exist;
      expect(instance._config.view.text).to.exist;
      expect(instance._config.view.text.branches).to.exist;
      expect(instance._config.view.text.branches.add_condition).to.exist;
      expect(instance._config.view.text.branches.add_condition).to.equal(TEXT_ADD_CONDITION);
    });

    it("should make the branch public", function() {
      var instance = $injector.data("instance");
      expect(instance.branch).to.exist;
      expect(instance.branch).to.equal(global_test_branch);
    });

    it("should add a condition when clicked", function() {
      expect(global_test_branch.$node.find(".condition").length).to.equal(1);
      $injector.click();
      expect(global_test_branch.$node.find(".condition").length).to.equal(2);
    });
  });


  describe("BranchQuestion", function() {
    var $question, question;

    before(function() {
      $question = $(BRANCH_QUESTION_SELECTOR);
      question = $question.data("instance");
    });

    it("should have the basic HTML in place", function() {
      // Just adding something basic here but it might change.
      expect($question.length).to.equal(1);
      expect($question.get(0).nodeName.toLowerCase()).to.equal("div");
    });

    it("should have the component class name present", function() {
      expect($question.hasClass("BranchQuestion")).to.be.true;
    });

    it("should make the $node public", function() {
      expect(question.$node).to.exist;
      expect(question.$node.length).to.equal(1);
      expect(question.$node.get(0)).to.equal($question.get(0));
    });

    it("should make (public but indicated as) private reference to config", function() {
      expect(question._config).to.exist;
      expect(question._config.selector_question).to.equal(BRANCH_QUESTION_SELECTOR);
    });

    describe("Clear", function() {
      var $condition;

      beforeEach(function() {
        question._$error = $("<p class=\"error-message\">Some error</p>");
        $question.append(question._$error);
        $condition = $(BRANCH_CONDITION_SELECTOR);
      });

      it("should remove the inserted error node", function() {
        expect($question.find(".error-message").length).to.equal(1);
        question.clear();
        expect($question.find(".error-message").length).to.equal(0);
      });

      it("should nullify the private reference to error node", function() {
        expect(question._$error).to.exist;
        question.clear();
        expect(question._$error).to.not.exist;
      });

      it("should remove the error class from condition node", function() {
        expect($condition.find(".error-message").length).to.equal(1);
        question.clear();
        expect($condition.find(".error-message").length).to.equal(0);
      });
    });

    describe("Error", function() {
      var $condition;

      before(function() {
        $condition = $(BRANCH_CONDITION_SELECTOR);
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
        expect(question._$error.text()).to.equal(ERROR_MESSAGE);
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

      it("should call condition.update on selection of supported question", function() {
        var condition = $(BRANCH_CONDITION_SELECTOR).data("instance");
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
        var condition = $(BRANCH_CONDITION_SELECTOR).data("instance");
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

      it("should clear error on change of question", function() {
/*
        var instance = $question.data("instance");
        var $error = $("<p class=\"error-message\"></p>");
      instance._$error = $error;
      $question.append($error);

      // Check it's all there...
      expect($question.find(".error-message").length).to.equal(1);
      expect(instance._$error).to.exist;
      expect(instance._$error).to.equal($error);

      // now activate the method...
      instance.clear();

      // and check it's all gone.
      expect(instance._$error).to.not.equal($error);
      expect(instance._$error).to.not.exist;
      expect($question.find(".error-message").length).to.equal(0);
*/
      });
    });
  });

  describe("BranchAnswer", function() {
    var $answer, get;

    before(function() {

      // Hijack $.get to fake a response
      get = $.get;
      $.get = function(urlNotNeeded, response) {
        response(`<div class="answer">
          <select><option>is</option></select>
          <select><option>This answer value</option></select>
        </div>`);
      }

      // Set the answer node and create a BranchAnswer by calling update() function
      $(BRANCH_CONDITION_SELECTOR).data("instance").update("asdfdfa");
      $answer = global_test_branch.$node.find(BRANCH_ANSWER_SELECTOR);
    });

    after(function() {
       // Reset to original function
       $answer.remove();
       $.get = get;
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

    it("should make (public but indicated as) private reference to config", function() {
      var instance = $answer.data("instance");
      expect(instance._config).to.exist;
      expect(instance._config.expression_url).to.equal(EXPRESSION_URL);
    });
  });
});
