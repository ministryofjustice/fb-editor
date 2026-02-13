class Questionnaire::Exit
  def is_valid?(questionnaire_answers)
    questionnaire_answers && questionnaire_answers[:continue_with_moj_forms] == 'false'
  end
end
