class FromAddressCreation
  include Model::ActiveModel
  attr_accessor :from_address, :from_address_params, :email_service

  def save
    from_address.update!(from_address_params)
    verify_email
  rescue ActiveRecord::RecordInvalid
    false
  end

  def verify_email
    if email_service.get_email_identity(from_address.email_address).blank?
      email_service.create_email_identity(from_address.email_address)
      Rails.logger.info("Created email identity for service #{from_address.service_id}")
    else
      if email_identity.sending_enabled && !from_address.verified
        from_address.update_column(:status, :verified)
        Rails.logger.info(
          "Updated from address status for service #{from_address.service_id} to verified"
        )
      elsif !email_identity.sending_enabled && from_address.verified
        from_address.update_column(:status, :unverified)
        Rails.logger.info(
          "Updated from address status for service #{from_address.service_id} to unverified"
        )
      end
    end
  end

  def status_changed?
  end

  def all_identities
    email_service.list_email_identities.email_identities
  end

  def email_identity
    all_identities.find { |i| i.email_address == from_address.email_address }
  end
end
