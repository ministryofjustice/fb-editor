class ContentSubstitutor
  attr_accessor :service_name, :reference_number_enabled

  CONFIG_WITH_DEFAULTS = %w[
    CONFIRMATION_EMAIL_SUBJECT
    CONFIRMATION_EMAIL_BODY
    SERVICE_EMAIL_SUBJECT
    SERVICE_EMAIL_BODY
    SERVICE_EMAIL_PDF_HEADING
  ].freeze

  def initialize(service_name:, reference_number_enabled:)
    @service_name = service_name
    @reference_number_enabled = reference_number_enabled
  end

  def confirmation_email_subject
    if reference_number_enabled
      I18n.t(
        'default_values.confirmation_email_subject',
        service_name: service_name
      ).gsub('{{reference_number_sentence}}', I18n.t('default_values.reference_number_sentence'))
    else
      I18n.t(
        'default_values.confirmation_email_subject',
        service_name: service_name
      ).gsub('{{reference_number_sentence}}', '')
    end
  end
end
