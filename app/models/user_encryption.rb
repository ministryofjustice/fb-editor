module UserEncryption
  def encrypt_attributes
    self.name = encrypt(raw_name) if respond_to?(:will_save_change_to_name?) && will_save_change_to_name?
    self.email = encrypt(raw_email) if respond_to?(:will_save_change_to_email?) && will_save_change_to_email?
  end

  def name
    decrypt(raw_name)
  end

  def email
    decrypt(raw_email)
  end

  def raw_name
    self[:name]
  end

  def raw_email
    self[:email]
  end

  def decrypt(value)
    return if value.blank?

    EncryptionService.new.decrypt(value)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    value
  end

  def encrypt(value)
    return if value.blank?

    EncryptionService.new.encrypt(value)
  end
end
