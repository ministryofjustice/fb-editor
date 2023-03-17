module ComponentValidations
  class MinimumValidation < BaseComponentValidation
    validates_with NumberValidator, if: :run_validation?

    DEFAULT_METADATA_KEY = 'minimum'.freeze

    def component_partial
      'minimum_maximum_validations'
    end

    def label
      I18n.t('dialogs.component_validations.minimum.label')
    end

    def status_label
      I18n.t('dialogs.component_validations.minimum.status_label')
    end
  end
end
