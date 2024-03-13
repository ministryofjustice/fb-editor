class PatternValidation < BaseComponentValidation
  attr_accessor :pattern
  DEFAULT_METADATA_KEY = 'pattern'.freeze

  with_options presence: {
    if: proc { |obj| obj.enabled? },
    message: I18n.t('activemodel.errors.models.string_regex_pattern.blank')
  } do
    validates :value
  end
  validates_with RegexValidator, if: :run_validation?


  def status_label
    I18n.t('dialogs.component_validations.string.pattern.status_label')
  end

  def label
    I18n.t('dialogs.component_validations.string.pattern.label')
  end

  def component_partial
    'string_regex_validation'
  end
end
