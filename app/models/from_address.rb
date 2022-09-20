class FromAddress < ApplicationRecord
  before_save :encrypt_email

  validates :email, format: {
    if: proc { |obj| obj.run_validation? },
    with: URI::MailTo::EMAIL_REGEXP,
    message: I18n.t('activemodel.errors.models.from_address.invalid')
  }, allow_blank: true
  validates :email, format: {
    if: proc { |obj| obj.run_validation? },
    with: /\A\b[A-Z0-9._%a-z\-]+@(digital\.justice|justice)\.gov\.uk\z/,
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

  # If the email is already encrypted then it won't be a
  # new user inputted value therefore do not run validate.
  # If it successfully decrypts then it is from the database
  def run_validation?
    EncryptionService.new.decrypt(email)
    false
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    true
  end

  private

  def encrypt_email
    self.email = EncryptionService.new.encrypt(email_address.presence || DEFAULT_EMAIL_FROM)
  end
end
