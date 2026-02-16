class Questionnaire::GovForms
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :govuk_forms_ruled_out, :boolean

  validates :govuk_forms_ruled_out,
            inclusion: { in: [true, false] }

  def govuk_forms_ruled_out_options
    [true, false].map do |option|
      OpenStruct.new(
        value: option,
        name: I18n.t("activemodel.attributes.questionnaire/gov_forms/govuk_forms_ruled_out.#{option}")
      )
    end
  end

  def valid?(questionnaire_answers)
    questionnaire_answers && questionnaire_answers[:new_form_reason] == Questionnaire::GetStartedForm::BUILDING
  end
end
