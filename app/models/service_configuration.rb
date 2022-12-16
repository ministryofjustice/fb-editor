class ServiceConfiguration < ApplicationRecord
  SECRETS = %w[
    BASIC_AUTH_USER
    BASIC_AUTH_PASS
    ENCODED_PRIVATE_KEY
    SERVICE_SECRET
  ].freeze
  SUBMISSION = %w[
    SERVICE_EMAIL_OUTPUT
    SERVICE_EMAIL_FROM
    SERVICE_EMAIL_SUBJECT
    SERVICE_EMAIL_BODY
    SERVICE_EMAIL_PDF_HEADING
    SERVICE_EMAIL_PDF_SUBHEADING
    SERVICE_CSV_OUTPUT
  ].freeze
  CONFIRMATION_EMAIL = %w[
    CONFIRMATION_EMAIL_COMPONENT_ID
    CONFIRMATION_EMAIL_SUBJECT
    CONFIRMATION_EMAIL_BODY
  ].freeze
  MAINTENANCE = %w[
    MAINTENANCE_PAGE_HEADING
    MAINTENANCE_PAGE_CONTENT
  ]
  BASIC_AUTH_USER = 'BASIC_AUTH_USER'.freeze
  BASIC_AUTH_PASS = 'BASIC_AUTH_PASS'.freeze
  REFERENCE_PARAM = '?reference='.freeze
  A_TAG = '<a href=\"{{payment_link}}\">{{payment_link}}</a>'.freeze

  before_save :encrypt_value

  validates :name, :value, :service_id, :deployment_environment, presence: true
  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :name, uniqueness: {
    scope: %i[service_id deployment_environment],
    case_sensitive: false
  }

  def secrets?
    name.in?(SECRETS)
  end

  def do_not_inject_payment_link?
    name == 'PAYMENT_LINK' &&
      SubmissionSetting.find_by(
        service_id: service_id,
        deployment_environment: deployment_environment
      ).try(:payment_link?).blank?
  end

  def do_not_send_submission?
    name.in?(SUBMISSION) &&
      SubmissionSetting.find_by(
        service_id: service_id,
        deployment_environment: deployment_environment
      ).try(:send_email?).blank?
  end

  def do_not_send_confirmation_email?
    name.in?(CONFIRMATION_EMAIL) &&
      SubmissionSetting.find_by(
        service_id: service_id,
        deployment_environment: deployment_environment
      ).try(:send_confirmation_email?).blank?
  end

  def not_in_maintenance_mode?
    name.in?(MAINTENANCE) &&
      ServiceConfiguration.find_by(
        service_id: service_id,
        deployment_environment: deployment_environment,
        name: 'MAINTENANCE_MODE'
      ).blank?
  end

  def decrypt_value
    if value.present?
      @decrypt_value ||=
        EncryptionService.new.decrypt(value)
    end
  end

  def encode64
    Base64.strict_encode64(decrypt_value) if decrypt_value.present?
  end

  def config_map_value
    send(name.downcase)
  rescue NoMethodError
    decrypt_value
  end

  private

  def payment_link
    decrypt_value + REFERENCE_PARAM
  end

  def confirmation_email_body
    inject_line_breaks(decrypt_value).gsub('{{payment_link}}', A_TAG)
  end

  def service_email_body
    inject_line_breaks(decrypt_value)
  end

  def inject_line_breaks(text)
    text.gsub(/\n|\r/, '<br />')
  end

  def encrypt_value
    self.value = EncryptionService.new.encrypt(value)
  end
end
