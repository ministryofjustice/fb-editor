class Questionnaire::GovUkForm
  # include ActiveModel::Model
  # include ActiveModel::AttributeAssignment
  # include ActiveModel::Validations

  include ActiveModel::API
  attr_accessor :govuk_forms_ruled_out

  validates :govuk_forms_ruled_out,
            presence: true,
            inclusion: { in: %w[true false] }
end
