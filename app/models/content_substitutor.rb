class ContentSubstitutor
  attr_accessor :service_name, :reference_number_enabled

  REFERENCE_NUMBER_PLACEHOLDER = '{{reference_number_sentence}}'.freeze

  def initialize(service_name:, reference_number_enabled:)
    @service_name = service_name
    @reference_number_enabled = reference_number_enabled
  end

  def confirmation_email_subject
    setting = I18n.t(
      'default_values.confirmation_email_subject',
      service_name: service_name
    )
    if reference_number_enabled
      insert_placeholder_sentence(
        setting,
        REFERENCE_NUMBER_PLACEHOLDER,
        I18n.t('default_values.reference_number_subject')
      )
    else
      remove_placeholder_sentence(setting, REFERENCE_NUMBER_PLACEHOLDER)
    end
  end

  def confirmation_email_body
    setting = I18n.t(
      'default_values.confirmation_email_body',
      service_name: service_name
    )
    if reference_number_enabled
      insert_placeholder_sentence(
        setting,
        REFERENCE_NUMBER_PLACEHOLDER,
        I18n.t('default_values.reference_number_sentence')
      )
    else
      remove_placeholder_sentence(setting, REFERENCE_NUMBER_PLACEHOLDER)
    end
  end

  def service_email_subject
    setting = I18n.t(
      'default_values.service_email_subject',
      service_name: service_name
    )
    if reference_number_enabled
      insert_placeholder_sentence(
        setting,
        REFERENCE_NUMBER_PLACEHOLDER,
        I18n.t('default_values.reference_number_subject')
      )
    else
      remove_placeholder_sentence(setting, REFERENCE_NUMBER_PLACEHOLDER)
    end
  end

  def service_email_body
    setting = I18n.t(
      'default_values.service_email_body',
      service_name: service_name
    )
    if reference_number_enabled
      insert_placeholder_sentence(
        setting,
        REFERENCE_NUMBER_PLACEHOLDER,
        I18n.t('default_values.reference_number_sentence')
      )
    else
      remove_placeholder_sentence(setting, REFERENCE_NUMBER_PLACEHOLDER)
    end
  end

  def service_email_pdf_heading
    setting = I18n.t(
      'default_values.service_email_pdf_heading',
      service_name: service_name
    )
    if reference_number_enabled
      insert_placeholder_sentence(
        setting,
        REFERENCE_NUMBER_PLACEHOLDER,
        I18n.t('default_values.reference_number_subject')
      )
    else
      remove_placeholder_sentence(setting, REFERENCE_NUMBER_PLACEHOLDER)
    end
  end

  private

  def insert_placeholder_sentence(setting, placeholder, content)
    setting.gsub(placeholder, content)
  end

  def remove_placeholder_sentence(setting, placeholder)
    setting.gsub(placeholder, '')
  end
end
