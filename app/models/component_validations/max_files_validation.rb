class MaxFilesValidation < BaseComponentValidation
  validates_with MaxFilesValidator, if: :run_validation?

  DEFAULT_METADATA_KEY = 'max_files'.freeze

  def component_partial
    'max_file_validations'
  end

  def label
    I18n.t('dialogs.component_validations.max_files.label')
  end

  def hint
    I18n.t('dialogs.component_validations.max_files.hint')
  end
end
