class StringComponentLengthValidation < BaseComponentValidation
  attr_accessor :string_length
  validates_with NumberValidator, if: :run_validation?

  def component_partial
    'string_length_validation'
  end

  def preselect_characters?
    previously_enabled? || no_string_length_validations_configured?
  end

  # Need to override the base component version of this to make use of string_length
  # attribute as that is the actual validator name
  def previously_enabled?
    component_validation.key?(string_length)
  end

  def to_metadata
    return self.class::STRING_LENGTH_KEYS.index_with { |_| '' } if status.blank?

    meta = default_metadata(string_length)
    meta[string_length] = main_value

    if component_validation.key?(unused_validation)
      meta.merge({ unused_validation => '' })
    else
      meta
    end
  end

  private

  def no_string_length_validations_configured?
    @no_string_length_validations_configured ||=
      (component.supported_validations & component_validation.keys).blank?
  end

  def unused_validation
    @unused_validation ||= (self.class::STRING_LENGTH_KEYS - [string_length]).first
  end
end
