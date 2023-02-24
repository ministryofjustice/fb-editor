class FromAddressCreation
  include ActiveModel::Model
  attr_accessor :from_address, :email_service

  delegate :allowed_domain?, to: :from_address

  def save
    return if from_address.invalid?

    return if saved_email_address.present? && saved_email_address == from_address.email

    if (ENV['REPLY_TO'] == 'enabled')
      from_address.verified!
    else
      from_address.status = verify_email
    end
    from_address.save!
  rescue ActiveRecord::RecordInvalid
    false
  rescue EmailServiceError
    from_address.errors.add(:base, I18n.t('activemodel.errors.models.from_address.email_service_error'))
    false
  end

  def verify_email
    return :default if use_default_email?

    identity = email_service.get_email_identity(from_address.email)

    if identity.blank?
      # Although we save all email addresses with the status as 'pending',
      # we only want to call AWS if the domain is on the allow list
      email_service.create_email_identity(from_address.email) if allowed_domain?

      Rails.logger.info("Created email identity for service #{from_address.service_id}")
      :pending

    elsif email_identity.sending_enabled && !from_address.verified?
      Rails.logger.info(
        "Updated from address status for service #{from_address.service_id} to verified"
      )
      :verified

    elsif identity.present? && !email_identity.sending_enabled
      resend_validation

      Rails.logger.info(
        "From address for #{from_address.service_id} present in AWS and unverified. Resend validation and change status to pending."
      )
      :pending
    end
  end

  def resend_validation
    response = email_service.delete_email_identity(email_address)

    # A blank response means the email address was not found. This is
    # because the email identity was not created in the first place as
    # we do not create an email identity for emails that are not
    # initially on the allow list
    if response.blank? || response.successful?
      Rails.logger.info("Creating email identity for service #{from_address.service_id}")

      email_service.create_email_identity(email_address)
    else
      Rails.logger.info("Delete email identity unsuccessful for service #{from_address.service_id}")

      nil
    end
  rescue EmailServiceError
    Rails.logger.info("Resend Validation unsuccessful for service #{from_address.service_id}")

    nil
  end

  def all_identities
    email_service.list_email_identities.email_identities
  end

  def email_identity
    all_identities.find { |i| i.identity_name == from_address.email }
  end

  private

  def saved_email_address
    @saved_from_address ||= FromAddress.find_by(
      service_id: from_address.service_id
    )
    if @saved_from_address.nil?
      return nil
    end

    @saved_from_address.email_address
  end

  def use_default_email?
    from_address.email.blank? ||
      from_address.email == FromAddress::DEFAULT_EMAIL_FROM
  end

  def email_address
    @from_address.decrypt_email
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    @from_address.email
  end
end
