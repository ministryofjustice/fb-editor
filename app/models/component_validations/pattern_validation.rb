class PatternValidation < BaseComponentValidation
  attr_accessor :string_length

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