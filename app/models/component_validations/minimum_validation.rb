class MinimumValidation < BaseComponentValidation
  validates_with NumberValidator, if: :run_validation?

  DEFAULT_METADATA_KEY = 'minimum'.freeze

  def component_partial
    'minimum_validation'
  end

  def label
    I18n.t('dialogs.component_validations.minimum.label')
  end

  def status_label
    I18n.t('dialogs.component_validations.minimum.status_label')
  end

  def to_metadata
    return { DEFAULT_METADATA_KEY => '' } if status.blank?

    meta = default_metadata(DEFAULT_METADATA_KEY)
    meta[DEFAULT_METADATA_KEY] = value
    meta
  end
end
