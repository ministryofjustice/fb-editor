class Questionnaire::FormFeaturesForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :required_moj_forms_features, array: true
  attribute :govuk_forms_ruled_out_reason, :string

  MAX_CHARS = 500
  REQUIRED_MOJ_FORMS_FEATURE_OPTIONS = %w[
    multiple_questions
    multiple_branches
    control_visibility
    save_progress
    collect_responses
    hosting_off
    something_else
  ].freeze

  validates :required_moj_forms_features,
            inclusion: { in: REQUIRED_MOJ_FORMS_FEATURE_OPTIONS }

  validates :govuk_forms_ruled_out_reason,
            presence: true

  def required_moj_forms_features_options
    REQUIRED_MOJ_FORMS_FEATURE_OPTIONS.map do |option|
      OpenStruct.new(value: option, name:  I18n.t("activemodel.attributes.questionnaire/form_features_form/required_moj_forms_features.#{option}"))
    end
  end

  def is_valid?(questionnaire_answers)
    questionnaire_answers && questionnaire_answers[:govuk_forms_ruled_out] == 'true'
  end
end
