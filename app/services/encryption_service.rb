class EncryptionService
  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def encrypt(value)
    encrypt_and_sign(value)
  end

  def decrypt(value)
    decrypt_and_verify(value)
  end

  private

  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(key)
  end

  def key
    ActiveSupport::KeyGenerator.new(
      ENV.fetch('ENCRYPTION_KEY')
    ).generate_key(
      ENV.fetch('ENCRYPTION_SALT'),
      ActiveSupport::MessageEncryptor.key_len
    ).freeze
  end
end
