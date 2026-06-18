class NewEncryptionService < EncryptionService
  NEW_KEY = ActiveSupport::KeyGenerator.new(
    ENV.fetch('NEW_ENCRYPTION_KEY', '')
  ).generate_key(
    ENV.fetch('NEW_ENCRYPTION_SALT', ''),
    ActiveSupport::MessageEncryptor.key_len
  ).freeze

  private_constant :NEW_KEY

  private

  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(NEW_KEY)
  end
end
