class QuestionFlow
  # QUESTIONS = %i[new_form_reason govuk_forms_ruled_out great_choice q4].freeze

  def initialize(answers)
    @answers = answers
  end

  # def first
  #   :get_started
  # end

  def next(current)
    case current
    when :get_started
      @answers[:new_form_reason] == 'building' ? :gov_forms : :great_choice
    when :gov_forms
      :great_choice
    when :great_choice
      :q4
    end
  end
end
