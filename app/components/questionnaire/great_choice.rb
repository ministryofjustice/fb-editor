class Questionnaire::GreatChoice
  def is_valid?(questionnaire_answers)
    questionnaire_answers && questionnaire_answers[:new_form_reason] == Questionnaire::GetStartedForm::EXPERIMENT
  end
end
