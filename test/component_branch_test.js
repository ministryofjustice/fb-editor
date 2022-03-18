require("./setup");

describe("Branch", function () {

  const Branch = require('../app/javascript/src/component_branch.js');
  const COMPONENT_ID = "testing-branch";
  const BRANCH_DESTINATION_SELECTOR = ".destination";
  const BRANCH_CONDITION_SELECTOR = ".condition";
  const BRANCH_CONDITION_ADD_SELECTOR = ".condition-injector";
  const BRANCH_CONDITION_REMOVE_SELECTOR = ".condition-remover";
  const BRANCH_ERROR_MESSAGE_CLASSNAME = "test-error-message";
  const BRANCH_QUESTION_SELECTOR = ".question";
  const BRANCH_ANSWER_SELECTOR = ".answer";
  const BRANCH_REMOVE_SELECTOR = ".branch-remover";
  const EXPRESSION_URL = "/not/needed";
  const LABEL_QUESTION_AND = "And";
  const TEXT_ADD_CONDITION = "add condition text";
  const TEXT_REMOVE_BRANCH = "remove branch text";
  const TEXT_REMOVE_CONDITION = "remove condition text";
  const ERROR_MESSAGE = "This is an error message";
  const ERROR_CLASSNAME_1 = "error-classname-1";
  const ERROR_CLASSNAME_2 = "error-classname-2";

  const INDEX_BRANCH = 4;
  var global_test_branch;

  function createBranch(id, config) {
    var html = `<div class="branch" id="` + id + `">
        <p>Branch ...</p>
        <ul class="govuk-navigation component-activated-menu">
          <li>
            <a class="branch-remover">` + TEXT_REMOVE_BRANCH + `</a>
          </li>
        </ul>
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
          <div class="answer">
            <select><option>is</option></select>
            <select><option>This answer value</option></select>
          </div>
          <button class="condition-remover">` + TEXT_REMOVE_BRANCH + `</button>
        </div>
        <button class="condition-injector">` + TEXT_ADD_CONDITION + `</button>
      </div>`;

    var $node = $(html);
    var conf = {
      branch_index: INDEX_BRANCH,
      css_classes_error: ERROR_CLASSNAME_1 + " " + ERROR_CLASSNAME_2,
      selector_answer: BRANCH_ANSWER_SELECTOR,
      selector_branch_remove: BRANCH_REMOVE_SELECTOR,
      selector_condition: BRANCH_CONDITION_SELECTOR,
      selector_condition_add: BRANCH_CONDITION_ADD_SELECTOR,
      selector_condition_remove: BRANCH_CONDITION_REMOVE_SELECTOR,
      selector_destination: BRANCH_DESTINATION_SELECTOR,
      selector_question: BRANCH_QUESTION_SELECTOR,
      selector_error_messsage: "." + BRANCH_ERROR_MESSAGE_CLASSNAME,
      expression_url: EXPRESSION_URL,
      question_label: LABEL_QUESTION_AND,
      template_condition: "<div class=\"condition\">dummy</div>",
      view: {
        text: {
          branches: {
            condition_add: TEXT_ADD_CONDITION,
            condition_remove: TEXT_REMOVE_CONDITION
          },
          dialogs: {
            heading_delete_condition: "Heading delete condition",
            button_delete_message: "Message delete condition",
            button_delete_condition: "Button delete condition",
            heading_delete_branch: "Heading delete branch",
            message_delete_branch: "Message delete branch",
            button_delete_branch: "Button delete branch"
          },
          errors: {
            branches: {
              unsupported_question: ERROR_MESSAGE
            }
          }
        }
      }
    }

    // Include any passed config items.
    if(config) {
      for(var prop in config) {
        if(config.hasOwnProperty(prop)) {
          conf[prop] = config[prop];
        }
      }
    }

    return {
      html: html,
      $node: $node,
      branch: new Branch($node, conf)
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
      expect(global_test_branch.view.text.branches.condition_add).to.equal(TEXT_ADD_CONDITION);
    });

    it("should make the destination public", function() {
      expect(global_test_branch.destination).to.exist;
    });

    it("should make the condition injector public", function() {
      expect(global_test_branch.conditionInjector).to.exist;
    });

    it("should make the index value public", function() {
      expect(global_test_branch.index).to.exist;
      expect(global_test_branch.index).to.equal(INDEX_BRANCH);
    });

    it("should make private index value available", function() {
      expect(global_test_branch.index).to.exist;
      expect(global_test_branch.index).to.equal(INDEX_BRANCH);
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

    it("should make private index value available", function() {
      var instance = $condition.data("instance");
      expect(instance.index).to.equal(0);
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

        $condition.find(BRANCH_ANSWER_SELECTOR).remove(); // First remove the hardcoded .answer element.
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
      $injector = global_test_branch.$node.find(".BranchConditionInjector");
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

  describe("BranchConditionRemover", function() {
    var $remover, remover;

    before(function() {
      var $condition = $(BRANCH_CONDITION_SELECTOR);
      $remover = $condition.find("button").eq(0);
      remover = $remover.data("instance");
    });

    it("should have basic HTML in place", function() {
      expect($remover.length).to.equal(1);
      expect($remover.get(0).nodeName.toLowerCase()).to.equal("button");
    });

    it("should have the component class name present", function() {
      expect($remover.hasClass("BranchConditionRemover")).to.be.true;
    });

    it("should make the $node public", function() {
      expect(remover.$node).to.exist;
      expect(remover.$node.length).to.equal(1);
      expect(remover.$node.get(0)).to.equal($remover.get(0));
    });

    it("should make the instance available as data on the $node", function() {
      expect(remover).to.exist;
      expect(remover.$node.length).to.equal(1);
    });

    it("should make a public reference to connected condition", function() {
      expect(remover.condition).to.exist;
      expect(remover.condition.$node.length).to.equal(1);
    });

    describe("confirm", function() {
      it("should run the activate function if no dialog exists in config", function() {
        var check = 1;
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
        var confirmTest = createBranch("confirmTest", {
          dialog_delete: {
            open: function() {
              ++check;
            }
          }
        });

        var $confirmTestCondition = $(BRANCH_CONDITION_SELECTOR, confirmTest.$node);
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
        check = 1;

        // First check value is correct...
        expect(check).to.equal(1);

        // Activate method and check value has increased.
        remover.activate();
        expect(check).to.equal(2);
      });
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

    it("should make the instance available as data on the $node", function() {
      var instance = $question.data("instance");
      expect(instance).to.exist;
      expect(instance.$node.length).to.equal(1);
    });

    describe("clearErrorState", function() {
      var $condition;

      beforeEach(function() {
        question._$error = $("<p class=\"error-message\">Some error</p>");
        $question.append(question._$error);
        $condition = $(BRANCH_CONDITION_SELECTOR);
      });

      afterEach(function() {
        $question.find(".error-message").remove();
        question._$error = null;
      });

      it("should remove the inserted error node", function() {
        expect($question.find(".error-message").length).to.equal(1);
        question.clearErrorState();
        expect($question.find(".error-message").length).to.equal(0);
      });

      it("should nullify the private reference to error node", function() {
        expect(question._$error).to.exist;
        question.clearErrorState();
        expect(question._$error).to.not.exist;
      });

      it("should remove the error class from condition node", function() {
        expect($condition.find(".error-message").length).to.equal(1);
        question.clearErrorState();
        expect($condition.find(".error-message").length).to.equal(0);
      });

      it("should remove template injected error message identified in config", function() {
        // Insert a test error message
        $question.append("<p class=\"" + BRANCH_ERROR_MESSAGE_CLASSNAME + "\">" + ERROR_MESSAGE  + "</p>");

        // Check it's there
        expect($question.find("." + BRANCH_ERROR_MESSAGE_CLASSNAME).length).to.equal(1);

        // Call the method and recheck for existence
        question.clearErrorState();
        expect($question.find("." + BRANCH_ERROR_MESSAGE_CLASSNAME).length).to.equal(0);
      });

      it("should remove template injected error class identified in config", function() {
        // First add some classes
        $question.addClass(ERROR_CLASSNAME_1);
        $question.find("select").addClass(ERROR_CLASSNAME_2);

        // Then check they exist
        expect($question.hasClass(ERROR_CLASSNAME_1)).to.be.true;
        expect($question.find("select").hasClass(ERROR_CLASSNAME_2)).to.be.true;
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

    it("should make the instance available as data on the $node", function() {
      var instance = $answer.data("instance");
      expect(instance).to.exist;
      expect(instance.$node.length).to.equal(1);
    });
  });

  describe("BranchRemover", function() {
    var $remover, created, remover;
    before(function() {
      created = createBranch("for-testing-branch-remover");
      global_test_branch.$node.after(created.branch.$node);
      $remover = created.branch.$node.find(BRANCH_REMOVE_SELECTOR);
      remover = $remover.data("instance");
    });

    it("should have the basic HTML in place", function() {
      expect($remover.length).to.equal(1);
      expect($remover.get(0).nodeName.toLowerCase()).to.equal("a");
      expect($remover.text()).to.equal(TEXT_REMOVE_BRANCH);
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
      created.branch.destroy = function() {
        check += 1;
      }

      expect(check).to.equal(1);

      $remover.click();
      expect(check).to.equal(2);

      created.branch.destroy = created.branch.constructor.prototype.destroy;
    });

    describe("confirm", function() {
      it("should run the activate function if no dialog exists in config", function() {
        var check = 1;
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

    describe("activate", function() {
      var check, branch, originalDestroy;

      before(function() {
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
        check = 1;

        // First check value is correct...
        expect(check).to.equal(1);

        // Activate method and check value has increased.
        remover.activate();
        expect(check).to.equal(2);
      });
    });

  });
});
