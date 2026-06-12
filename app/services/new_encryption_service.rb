class NewEncryptionService < EncryptionService
  KEY = ActiveSupport::KeyGenerator.new(
    ENV.fetch('NEW_ENCRYPTION_KEY', '')
  ).generate_key(
    ENV.fetch('NEW_ENCRYPTION_SALT', ''),
    ActiveSupport::MessageEncryptor.key_len
  ).freeze
end