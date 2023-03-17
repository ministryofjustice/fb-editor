module ComponentValidations
  class DateAfterValidation < DateValidation
    DEFAULT_METADATA_KEY = 'date_after'.freeze

    def component_partial
      'date_after_before_validations'
    end

    def label
      I18n.t('dialogs.component_validations.date_after.label')
    end

    def status_label
      I18n.t('dialogs.component_validations.date_after.status_label')
    end
  end
end
