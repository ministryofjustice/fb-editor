class Questionnaire::ContinueForm
  include ActiveModel::API
  attr_accessor :continue_with_moj_forms

  validates :continue_with_moj_forms,
            presence: true,
            inclusion: { in: %w[true false] }

  def continue_with_moj_forms_options
    %w[true false].map do |option|
      OpenStruct.new(
        value: option,
        name: I18n.t("activemodel.attributes.questionnaire/continue_form.continue_with_moj_forms_#{option}")
      )
    end
  end
end
