class Questionnaire::GetStartedForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :new_form_reason, :string

  BUILDING = 'building'.freeze
  EXPERIMENT = 'experiment'.freeze

  NEW_FORM_REASON_OPTIONS = [BUILDING, EXPERIMENT].freeze

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

  def previous_step_completed?(_questionnaire_answers)
    true
  end
end
