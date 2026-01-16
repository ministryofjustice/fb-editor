class Questionnaire::FormFeaturesForm
  include ActiveModel::API
  attr_accessor :required_moj_forms_features, :govuk_forms_ruled_out_reason

  REQUIRED_MOJ_FORMS_FEATURE_OPTIONS = %w[multiple_questions multiple_branches control_visibility save_progress collect_responses hosting_off something_else].freeze
  MAX_CHARS = 500
  validates :required_moj_forms_features,
            inclusion: { in: REQUIRED_MOJ_FORMS_FEATURE_OPTIONS }

  validates :govuk_forms_ruled_out_reason,
            presence: true
end
