class Questionnaire::AttributesExtractor
  attr_reader :questionnaire

  ALLOWED_KEYS = {
    experiment: %i[new_form_reason],

    ruled_out: %i[
      new_form_reason
      govuk_forms_ruled_out
      required_moj_forms_features
      govuk_forms_ruled_out_reason
      estimated_page_count
      estimated_first_year_submissions_count
      submission_delivery_method
    ],

    continue_with_moj: %i[
      new_form_reason
      govuk_forms_ruled_out
      continue_with_moj_forms
      estimated_page_count
      estimated_first_year_submissions_count
      submission_delivery_method
    ]
  }.freeze

  def initialize(questionnaire)
    @questionnaire = questionnaire
  end

  def extract!
    return {} if questionnaire.blank?

    if questionnaire[:new_form_reason] == Questionnaire::GetStartedForm::EXPERIMENT
      questionnaire.slice!(*ALLOWED_KEYS[:experiment])
    end

    if questionnaire[:govuk_forms_ruled_out] == 'true'
      questionnaire.slice!(*ALLOWED_KEYS[:ruled_out])
    end

    if questionnaire[:govuk_forms_ruled_out] == 'false' && questionnaire[:continue_with_moj_forms] == 'true'
      questionnaire.slice!(*ALLOWED_KEYS[:continue_with_moj])
    end

    if questionnaire[:govuk_forms_ruled_out] == 'false' && questionnaire[:continue_with_moj_forms] == 'false'
      questionnaire.clear
    end
    questionnaire
  end
end
