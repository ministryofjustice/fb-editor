class Questionnaire::Requirements
  def previous_step_completed?(questionnaire_answers)
    return false unless questionnaire_answers

    %i[
      estimated_page_count
      estimated_first_year_submissions_count
      submission_delivery_method
    ].all? { |key| questionnaire_answers[key].present? }
  end
end
