namespace :db do
  desc 'Rotate encryption keys'
  task rotate_encryption_key: :environment do
    old_encryption = EncryptionService.new
    new_encryption = NewEncryptionService.new

    rotate_records = lambda do |model, attributes, old_enc, new_enc|
      model.transaction do
        model.find_each do |record|
          updates = attributes do |attribute|
            encrypted_value = record.attributes_before_type_cast[attribute]

            decrypted_value = old_enc.decrypt(encrypted_value)

            [
              attribute,
              new_enc.encrypt(decrypted_value)
            ]
          end

          record.update_columns(updates)
        end
      end
    end

    rotate_records.call(
      Identity,
      %w[name email],
      old_encryption,
      new_encryption
    )

    rotate_records.call(
      User,
      %w[name email],
      old_encryption,
      new_encryption
    )

    rotate_records.call(
      ServiceConfiguration,
      %w[value],
      old_encryption,
      new_encryption
    )
  end
end
