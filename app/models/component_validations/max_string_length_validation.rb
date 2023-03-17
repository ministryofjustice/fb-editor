module ComponentValidations
  class MaxStringLengthValidation < StringComponentLengthValidation
    STRING_LENGTH_KEYS = %w[max_length max_word].freeze

    def label
      I18n.t('dialogs.component_validations.string.max.label')
    end

    def status_label
      I18n.t('dialogs.component_validations.string.max.status_label')
    end

    def characters_radio_value
      'max_length'
    end

    def words_radio_value
      'max_word'
    end
  end
end
