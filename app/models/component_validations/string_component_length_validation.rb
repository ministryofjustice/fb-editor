class StringComponentLengthValidation < BaseComponentValidation
  attr_accessor :string_length

  validates_with NumberValidator, if: :run_validation?

  CHARACTERS_VALIDATIONS = %w[max_length min_length].freeze
  WORDS_VALIDATIONS = %w[max_word min_word].freeze

  def component_partial
    'string_length_validation'
  end

  def select_characters?
    characters_validation_and_no_words_validation_previously_configured? ||
      characters_validation_previously_enabled? ||
      no_string_length_validations_configured?
  end

  def select_words?
    words_validation_and_no_characters_validation_previously_configured? ||
      words_validation_previously_enabled?
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

  # private

  # Need to override the base component version of this to make use of string_length
  # attribute as that is the actual validator name
  def previously_enabled?
    component_validation.key?(string_length)
  end

  def characters_validation_and_no_words_validation_previously_configured?
    string_length.in?(CHARACTERS_VALIDATIONS) && (component_validation.keys & WORDS_VALIDATIONS).blank?
  end

  def characters_validation_previously_enabled?
    WORDS_VALIDATIONS.exclude?(string_length) && previously_enabled?
  end

  def words_validation_and_no_characters_validation_previously_configured?
    string_length.in?(WORDS_VALIDATIONS) && (component_validation.keys & CHARACTERS_VALIDATIONS).blank?
  end

  def words_validation_previously_enabled?
    CHARACTERS_VALIDATIONS.exclude?(string_length) && previously_enabled?
  end

  def no_string_length_validations_configured?
    @no_string_length_validations_configured ||=
      string_length.blank? && (self.class::STRING_LENGTH_KEYS & component_validation.keys).blank?
  end

  def unused_validation
    @unused_validation ||= (self.class::STRING_LENGTH_KEYS - [string_length]).first
  end
end
