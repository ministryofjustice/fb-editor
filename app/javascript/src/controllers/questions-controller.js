import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["question"];
  connect() {
    console.log("questionS controller connected");
    console.log(this.questionTargets);
    this.element[`${this.identifier}Controller`] = this;
  }

  questionTargetDisconnected() {
    this.updateQuestionIndices();
  }

  moveUp(event) {
    console.log("up we go");
    console.log(event);
    const button = event.target;
    const question = event.target.closest('[data-controller="question"]');
    const currentIndex = question.questionController.indexValue;
    const newIndex = currentIndex - 1;
    const previousQuestion = this.questionTargets[newIndex];

    previousQuestion.before(question);
    button.focus();
    // question.questionController.indexValue = newIndex;
    this.updateQuestionIndices();
  }

  moveDown(event) {
    console.log("going down");
    console.log(event);
    const button = event.target;
    const question = event.target.closest('[data-controller="question"]');
    const currentIndex = question.questionController.indexValue;
    const newIndex = currentIndex + 1;
    const nextQuestion = this.questionTargets[newIndex];

    nextQuestion.after(question);
    button.focus();
    // question.questionController.indexValue = newIndex;
    this.updateQuestionIndices();
  }

  updateQuestionIndices() {
    this.questionTargets.forEach((question, idx) => {
      question.questionController.indexValue = idx;
    });
  }
}
