class PatternValidation < BaseComponentValidation
  attr_accessor :pattern

  DEFAULT_METADATA_KEY = 'pattern'.freeze

  with_options presence: {
    if: proc { |obj| obj.enabled? },
    message: 'Enter a regular expression'
  } do
    validates :value
  end

  def status_label
    'Set a specific answer format'
  end

  def label
    'Specific answer format'
  end

  def component_partial
    'string_regex_validation'
  end
end
