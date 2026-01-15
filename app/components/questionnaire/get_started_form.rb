module Questionnaire
  class GetStartedForm
    include ActiveModel::Model

    attr_reader :answers, :current_question

    validates :answer, presence: true

    def initialize(answers, current_question)
      @answers = answers
      @current_question = current_question
    end

    def answer
      answers[current_question]
    end
  end
end
