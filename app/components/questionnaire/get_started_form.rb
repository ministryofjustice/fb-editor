class Questionnaire::GetStartedForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :new_form_reason, :string

  NEW_FORM_REASON_OPTIONS = %w[
    building
    experiment
  ].freeze

  validates :new_form_reason,
            inclusion: { in: NEW_FORM_REASON_OPTIONS }

  def new_form_reason_options
    NEW_FORM_REASON_OPTIONS.map do |option|
      OpenStruct.new(
        value: option,
        name: I18n.t("activemodel.attributes.questionnaire/get_started_form/new_form_reason.#{option}")
      )
    end
  end
end
