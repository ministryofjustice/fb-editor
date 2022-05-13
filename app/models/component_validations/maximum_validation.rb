class MaximumValidation < BaseComponentValidation
  validates_with NumberValidator, if: :run_validation?

  DEFAULT_METADATA_KEY = 'maximum'.freeze

  def component_partial
    'maximum_validation'
  end

  def label
    I18n.t('dialogs.component_validations.maximum.label')
  end

  def status_label
    I18n.t('dialogs.component_validations.maximum.status_label')
  end

  def to_metadata
    meta = default_metadata(DEFAULT_METADATA_KEY)
    meta[DEFAULT_METADATA_KEY] = value
    meta
  end
end
