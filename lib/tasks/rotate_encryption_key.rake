namespace :db do
  desc 'Rotate encryption keys'
  task rotate_encryption_key: [:environment] do
    ## Identity ##
    Identity.transaction do
      Identity.find_each do |identity|
        name = identity.attributes_before_type_cast['name']
        email = identity.attributes_before_type_cast['email']

        decrypted_name = EncryptionService.new.decrypt(name)
        decrypted_email = EncryptionService.new.decrypt(email)

        new_encrypted_name = NewEncryptionService.new.encrypt(decrypted_name)
        new_encrypted_email = NewEncryptionService.new.encrypt(decrypted_email)

        identity.update_columns(
          name: new_encrypted_name,
          email: new_encrypted_email
        )
      end
    end

    ## User ##
    User.transaction do
      User.find_each do |user|
        name = user.attributes_before_type_cast['name']
        email = user.attributes_before_type_cast['email']

        decrypted_name = EncryptionService.new.decrypt(name)
        decrypted_email = EncryptionService.new.decrypt(email)

        new_encrypted_name = NewEncryptionService.new.encrypt(decrypted_name)
        new_encrypted_email = NewEncryptionService.new.encrypt(decrypted_email)

        user.update_columns(
          name: new_encrypted_name,
          email: new_encrypted_email
        )
      end
    end

    ## ServiceConfiguration ##
    ServiceConfiguration.transaction do
      ServiceConfiguration.find_each do |service_configuration|
        value = service_configuration.attributes_before_type_cast['value']

        decrypted_value = EncryptionService.new.decrypt(value)
        new_encrypted_value = NewEncryptionService.new.encrypt(decrypted_value)

        service_configuration.update_columns(
          value: new_encrypted_value
        )
      end
    end
  end
end
