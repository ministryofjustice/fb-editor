class Questionnaire::ContinueForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :continue_with_moj_forms, :boolean

  validates :continue_with_moj_forms,
            inclusion: { in: [true, false] }

  def continue_with_moj_forms_options
    [false, true].map do |option|
      OpenStruct.new(
        value: option,
        name: I18n.t("activemodel.attributes.questionnaire/continue_form/continue_with_moj_forms.#{option}")
      )
    end
  end

  def is_valid?(questionnaire_answers)
    questionnaire_answers && questionnaire_answers[:govuk_forms_ruled_out] == 'false'
  end
end
