class FromAddress < ApplicationRecord
  before_save :encrypt_email
  after_save :update_status

  validates :email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: I18n.t('activemodel.errors.models.from_address.invalid')
  }, allow_blank: true
  validates :email, format: {
    with: /\A\b[A-Z0-9._%a-z\-]+@(digital\.justice|justice|justice.gsi)\.gov\.uk\z/,
    message: I18n.t('activemodel.errors.models.from_address.invalid_domain')
  }, allow_blank: true

  enum status: {
    default: 0,
    pending: 1,
    verified: 2
  }

  DEFAULT_EMAIL_FROM = I18n.t('default_values.service_email_from')

  def email_address
    return DEFAULT_EMAIL_FROM if email.blank?

    decrypt_email
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    email
  end

  def decrypt_email
    @decrypt_email ||= EncryptionService.new.decrypt(email)
  end

  def default_email?
    email_address == DEFAULT_EMAIL_FROM
  end

  private

  def update_status
    update_status_column(:default) if email_address == DEFAULT_EMAIL_FROM
  end

  def update_status_column(status)
    update_column(:status, status)
  end

  def encrypt_email
    self.email = EncryptionService.new.encrypt(email.presence || DEFAULT_EMAIL_FROM)
  end
end
