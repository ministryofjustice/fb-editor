class QuestionnaireAnswersValidator
  REQUIRED_KEYS = %i[
    estimated_page_count
    estimated_first_year_submissions_count
    submission_delivery_method
  ].freeze

  def initialize(answers)
    @answers = answers
  end

  def valid?
    rules.all?(&:call)
  end

  private

  attr_reader :answers

  def rules
    [
      -> { answers_present? },
      -> { experiment? || required_fields_present? }
    ]
  end

  def answers_present?
    !answers.nil?
  end

  def experiment?
    answers[:new_form_reason] == Questionnaire::GetStartedForm::EXPERIMENT
  end

  def required_fields_present?
    REQUIRED_KEYS.all? { |key| answers[key].present? }
  end
end
