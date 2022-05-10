class DateBeforeValidation < DateValidation
  DEFAULT_METADATA_KEY = 'date_before'.freeze

  def component_partial
    'date_before_validation'
  end

  def label
    I18n.t('dialogs.component_validations.date_before.label')
  end

  def status_label
    I18n.t('dialogs.component_validations.date_before.status_label')
  end
end
