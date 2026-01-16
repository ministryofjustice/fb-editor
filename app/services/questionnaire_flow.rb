class QuestionnaireFlow
  def initialize(answers)
    @answers = answers
  end

  def next(current)
    case current.to_sym
    when :get_started
      @answers[:new_form_reason] == 'building' ? :gov_forms : :great_choice
    when :gov_forms
      @answers[:govuk_forms_ruled_out] == 'true' ? :form_features : :continue
    when :continue
      @answers[:continue_with_moj_forms] == 'true' ? :new_form : :exit
    when :form_features
      :new_form
    when :new_form
      :requirements
    when :requirements
      nil
    when :great_choice
      nil
    when :exit
      nil
    end
  end
end
