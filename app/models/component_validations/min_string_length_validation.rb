module ComponentValidations
  class MinStringLengthValidation < StringComponentLengthValidation
    STRING_LENGTH_KEYS = %w[min_length min_word].freeze

    def label
      I18n.t('dialogs.component_validations.string.min.label')
    end

    def status_label
      I18n.t('dialogs.component_validations.string.min.status_label')
    end

    def characters_radio_value
      'min_length'
    end

    def words_radio_value
      'min_word'
    end
  end
end