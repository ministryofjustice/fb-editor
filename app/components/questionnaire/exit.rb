class Questionnaire::Exit
  def previous_step_completed?(questionnaire_answers)
    questionnaire_answers[:continue_with_moj_forms] == 'false'
  end
end
