class Questionnaire::GetStartedForm
  include ActiveModel::API
  attr_accessor :new_form_reason

  NEW_FORM_REASON_OPTIONS = %w[building experiment].freeze

  validates :new_form_reason,
            presence: true,
            inclusion: { in: NEW_FORM_REASON_OPTIONS }
end
