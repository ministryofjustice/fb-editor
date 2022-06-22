class EnabledValidationsPresenter
  def initialize(component)
    @component = component
  end

  STRING_VALIDATIONS = %w[max_length min_length max_word min_word].freeze
  STRING_LENGTH_SUFFIX = '_string_length'.freeze

  def enabled_list
    validations = enabled_validations.map do |validation|
      if validation.in?(STRING_VALIDATIONS)
        "#{prefix(validation)}#{STRING_LENGTH_SUFFIX}"
      else
        validation
      end
    end
    validations.uniq
  end

  private

  attr_reader :component

  def enabled_validations
    Rails.application.config.enabled_validations & component.supported_validations
  end

  def prefix(validation)
    validation.split('_').first
  end
end
