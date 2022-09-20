class FromAddressCreation
  include ActiveModel::Model
  attr_accessor :from_address, :from_address_params, :email_service

  def save
    status = verify_email
    from_address.update!(from_address_params.merge(status: status))
  rescue ActiveRecord::RecordInvalid
    false
  rescue EmailServiceError
    from_address.errors.add(:base, I18n.t('activemodel.errors.models.from_address.email_service_error'))
    false
  end

  def verify_email
    return :default if use_default_email?

    if email_service.get_email_identity(from_address_params[:email]).blank?
      email_service.create_email_identity(from_address_params[:email])

      Rails.logger.info("Created email identity for service #{from_address.service_id}")
      :pending

    elsif email_identity.sending_enabled && !from_address.verified?
      Rails.logger.info(
        "Updated from address status for service #{from_address.service_id} to verified"
      )
      :verified
    elsif !email_identity.sending_enabled && from_address.verified?
      Rails.logger.info(
        "Updated from address status for service #{from_address.service_id} to default"
      )
      :default
    end
  end

  def all_identities
    email_service.list_email_identities.email_identities
  end

  def email_identity
    all_identities.find { |i| i.identity_name == from_address_params[:email] }
  end

  private

  def use_default_email?
    from_address_params[:email].blank? ||
      from_address_params[:email] == FromAddress::DEFAULT_EMAIL_FROM
  end
end
