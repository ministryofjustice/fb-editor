class ServiceConfiguration < ApplicationRecord
  SECRETS = %w[
    BASIC_AUTH_USER
    BASIC_AUTH_PASS
    ENCODED_PRIVATE_KEY
    SERVICE_SECRET
  ].freeze
  MS_GRAPH_SECRETS = %w[
    MS_ADMIN_APP_ID
    MS_ADMIN_APP_SECRET
    MS_OAUTH_URL
    MS_TENANT_ID
  ]
  MS_GRAPH_CONFIGURATION = %w[
    MS_LIST_ID
    MS_DRIVE_ID
    MS_SITE_ID
    MS_GRAPH_ROOT_URL
  ]
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
    CONFIRMATION_EMAIL_REPLY_TO
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

  def ms_graph_secrets?
    name.in?(MS_GRAPH_SECRETS)
  end

  def do_not_inject_payment_link?
    name == 'PAYMENT_LINK' &&
      SubmissionSetting.find_by(
        service_id:,
        deployment_environment:
      ).try(:payment_link?).blank?
  end

  def do_not_send_submission?
    name.in?(SUBMISSION) &&
      SubmissionSetting.find_by(
        service_id:,
        deployment_environment:
      ).try(:send_email?).blank?
  end

  def do_not_send_confirmation_email?
    name.in?(CONFIRMATION_EMAIL) &&
      SubmissionSetting.find_by(
        service_id:,
        deployment_environment:
      ).try(:send_confirmation_email?).blank?
  end

  def not_in_maintenance_mode?
    name.in?(MAINTENANCE) &&
      ServiceConfiguration.find_by(
        service_id:,
        deployment_environment:,
        name: 'MAINTENANCE_MODE'
      ).blank?
  end

  def do_not_send_to_graph_api?
    name.in?(MS_GRAPH_CONFIGURATION) &&
      SubmissionSetting.find_by(
        service_id:,
        deployment_environment:
      ).try(:send_to_graph_api?).blank?
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
    decrypt_value.gsub('"', '\"')
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
    text = text.gsub(/\n|\r/, '<br />')
    text.gsub('"', '\"')
  end

  def encrypt_value
    self.value = EncryptionService.new.encrypt(value)
  end
end
