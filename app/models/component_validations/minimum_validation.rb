class MinimumValidation < BaseComponentValidation
  validates_with NumberValidator, if: :run_validation?

  def component_partial
    'minimum_validation'
  end

  def label
    I18n.t('dialogs.component_validations.minimum.label')
  end

  def status_label
    I18n.t('dialogs.component_validations.minimum.status_label')
  end
end
