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
    content = I18n.t('default_values.reference_number_subject')

    substitute_placeholder(
      setting: setting,
      placeholder: REFERENCE_NUMBER_PLACEHOLDER,
      content: content
    )
  end

  def confirmation_email_body
    setting = I18n.t(
      'default_values.confirmation_email_body',
      service_name: service_name
    )
    content = I18n.t('default_values.reference_number_sentence')

    substitute_placeholder(
      setting: setting,
      placeholder: REFERENCE_NUMBER_PLACEHOLDER,
      content: content
    )
  end

  def service_email_subject
    setting = I18n.t(
      'default_values.service_email_subject',
      service_name: service_name
    )
    content = I18n.t('default_values.reference_number_subject')

    substitute_placeholder(
      setting: setting,
      placeholder: REFERENCE_NUMBER_PLACEHOLDER,
      content: content
    )
  end

  def service_email_body
    setting = I18n.t(
      'default_values.service_email_body',
      service_name: service_name
    )
    content = I18n.t('default_values.reference_number_sentence')

    substitute_placeholder(
      setting: setting,
      placeholder: REFERENCE_NUMBER_PLACEHOLDER,
      content: content
    )
  end

  def service_email_pdf_heading
    setting = I18n.t(
      'default_values.service_email_pdf_heading',
      service_name: service_name
    )
    content = I18n.t('default_values.reference_number_subject')

    substitute_placeholder(
      setting: setting,
      placeholder: REFERENCE_NUMBER_PLACEHOLDER,
      content: content
    )
  end

  private

  def insert_placeholder_sentence(setting, placeholder, content)
    setting.gsub(placeholder, content)
  end

  def remove_placeholder_sentence(setting, placeholder)
    setting.gsub(placeholder, '')
  end

  def substitute_placeholder(setting:, placeholder:, content:)
    if reference_number_enabled
      insert_placeholder_sentence(setting, placeholder, content)
    else
      remove_placeholder_sentence(setting, placeholder)
    end
  end
end
