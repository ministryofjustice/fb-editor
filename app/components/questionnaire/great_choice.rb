class Questionnaire::GreatChoice
  def previous_step_completed?(questionnaire_answers)
    questionnaire_answers[:new_form_reason] == Questionnaire::GetStartedForm::EXPERIMENT
  end
end
