namespace :db do
  desc 'Rotate encryption keys'
  task rotate_encryption_key: :environment do
    rotate_records = lambda do |model, attributes, old_enc = EncryptionService.new, new_enc = NewEncryptionService.new|
      model.transaction do
        records = model.all
        count = records.count

        puts "\nEncrypting #{model}: #{count} records\n"
        records.each do |record|
          updates = attributes.map do |attribute|
            encrypted_value = record.attributes_before_type_cast[attribute]
            decrypted_value = old_enc.decrypt(encrypted_value)
            new_encrypted_value = new_enc.encrypt(decrypted_value)

            [
              attribute,
              new_encrypted_value
            ]
          end

          record.update_columns(updates.to_h)
        end
        puts "Updated #{model}: #{count} records"
      end
    end

    rotate_records.call(
      Identity,
      %w[name email]
    )

    rotate_records.call(
      User,
      %w[name email]
    )

    rotate_records.call(
      ServiceConfiguration,
      %w[value]
    )
  end
end
