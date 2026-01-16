class Questionnaire::GovForms
  include ActiveModel::API
  attr_accessor :govuk_forms_ruled_out

  validates :govuk_forms_ruled_out,
            presence: true,
            inclusion: { in: %w[true false] }

  def govuk_forms_ruled_out_options
    %w[true false].map do |option|
      OpenStruct.new(
        value: option,
        name: I18n.t("activemodel.attributes.questionnaire/gov_forms_form.govuk_forms_ruled_out_#{option}")
      )
    end
  end
end
