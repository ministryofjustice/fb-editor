require("./setup");

describe("Branch", function () {

  const Branch = require('../app/javascript/src/component_branch.js');
  const COMPONENT_ID = "testing-branch";
  const BRANCH_CONDITION_SELECTOR = ".condition";
  const BRANCH_DESTINATION_SELECTOR = ".destination";
  const BRANCH_QUESTION_SELECTOR = ".question";
  const BRANCH_ANSWER_SELECTOR = ".answer";
  const EXPRESSION_URL = "something/goes/here";
  const INDEX_QUESTION = 2;
  var branch;

  before(function() {
    var $html = $(`<div class="branch" id="` + COMPONENT_ID + `" data-branch-index="0">
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
        <div class="question" data-question-index="` + INDEX_QUESTION  + `">
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
      question_selector: BRANCH_QUESTION_SELECTOR,
      expression_url: EXPRESSION_URL,
      attribute_question_index: "question-index",
      view: {
        text: "Something, something, something... darkside."
      }
    });
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

  describe("BranchQuestion", function() {
    var $question;

    beforeEach(function() {
      $question = $(BRANCH_QUESTION_SELECTOR);
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
      var instance = $question.data("instance");
      expect(instance.$node).to.exist;
      expect(instance.$node.length).to.equal(1);
      expect(instance.$node.get(0)).to.equal($question.get(0));
    });

    it("should make (public but indicated as) private reference to config", function() {
      var instance = $question.data("instance");
      expect(instance._config).to.exist;
      expect(instance._config.question_selector).to.equal(BRANCH_QUESTION_SELECTOR);
    });

    it("should assign an index value and make public", function() {
      var instance = $question.data("instance");
      expect(instance.index).to.equal(INDEX_QUESTION);
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
         // Reset to original function
         branch.condition.$node.find(BRANCH_ANSWER_SELECTOR).remove();
         $.get = get;
      });

      it("should add html for answer on selected question", function() {
        var question = $question.data("instance");
        var $condition = branch.condition.$node;

        expect($condition).to.exist;
        expect($condition.length).to.equal(1);
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(0);

        expect(question).to.exist;
        question.update("component-id-here");
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(1);
      });

      it("should remove html for answer on deselected question", function() {
        var question = $question.data("instance");
        var $condition = branch.condition.$node;
        expect(question).to.exist;
        expect($condition).to.exist;
        expect($condition.length).to.equal(1);

        // Fake an existing Answer element.
        question._answer = {
          $node: $("<div class=\"answer BranchAnswer\"></div>")
        }

        $condition.append(question._answer.$node);
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(1);

        question.update();
        expect($condition.find(BRANCH_ANSWER_SELECTOR).length).to.equal(0);
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
      $(BRANCH_QUESTION_SELECTOR).data("instance").update("asdfdfa");
      $answer = branch.$node.find(BRANCH_ANSWER_SELECTOR);
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
