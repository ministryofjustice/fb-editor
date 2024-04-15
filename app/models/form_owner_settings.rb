class FormOwnerSettings
  include ActiveModel::Model
  attr_accessor :form_owner, :service_id

  def update
    return false if @form_owner.blank?

    return false unless @form_owner.match(URI::MailTo::EMAIL_REGEXP)

    if email_exists?
      # then we have to update the metadata and show an information modal
      true
    else
      errors.add(:base, :invalid, message: 'User must exist in our user DB')
    end
  end

  private

  def email_exists?
    owner_email = EncryptionService.new.encrypt(@form_owner)
    User.where(email: owner_email).present?
  end
end
