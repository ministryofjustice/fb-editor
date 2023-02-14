class ContentSubstitutor
  attr_accessor :service_name, :reference_number_enabled, :payment_link_enabled

  REFERENCE_NUMBER_PLACEHOLDER = '{{reference_number_placeholder}}'.freeze
  REFERENCE_PAYMENT_PLACEHOLDER = '{{reference_payment_placeholder}}'.freeze

  def initialize(service_name:, reference_number_enabled:, payment_link_enabled:)
    @service_name = service_name
    @reference_number_enabled = reference_number_enabled
    @payment_link_enabled = payment_link_enabled
  end

  def confirmation_email_subject
    substitute_placeholder(
      setting: setting_content('confirmation_email_subject'),
      content: subject_content
    )
  end

  def confirmation_email_body
    substitute_placeholder(
      setting: setting_content('confirmation_email_body'),
      content: reference_payment_body_content,
      placeholder: REFERENCE_PAYMENT_PLACEHOLDER
    )
  end

  def service_email_subject
    substitute_placeholder(
      setting: setting_content('service_email_subject'),
      content: subject_content
    )
  end

  def service_email_body
    substitute_placeholder(
      setting: setting_content('service_email_body'),
      content: body_content
    )
  end

  def service_email_pdf_heading
    substitute_placeholder(
      setting: setting_content('service_email_pdf_heading'),
      content: subject_content
    )
  end

  def assign(setting)
    public_send(setting)
  rescue NoMethodError
    nil
  end

  private

  def setting_content(property)
    I18n.t("default_values.#{property}", service_name:)
  end

  def subject_content
    @subject_content ||= setting_content('reference_number_subject')
  end

  def body_content
    @body_content ||= setting_content('reference_number_sentence')
  end

  def reference_payment_body_content
    if payment_link_enabled
      I18n.t('default_values.reference_payment_sentence')
    else
      body_content
    end
  end

  def insert_placeholder_sentence(setting, placeholder, content)
    setting.gsub(placeholder, content)
  end

  def remove_placeholder_sentence(setting, placeholder)
    setting.gsub(placeholder, '')
  end

  def substitute_placeholder(setting:, content:, placeholder: REFERENCE_NUMBER_PLACEHOLDER)
    if reference_number_enabled
      insert_placeholder_sentence(setting, placeholder, content)
    else
      remove_placeholder_sentence(setting, placeholder)
    end
  end
end
