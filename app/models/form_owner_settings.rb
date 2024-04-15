class FormOwnerSettings
  include ActiveModel::Model
  attr_accessor :form_owner, :service_id

  def update
    if @form_owner.blank?
      errors.add(:base, :invalid, message: 'Email cannot be blank')
      return false
    end

    unless @form_owner.match(URI::MailTo::EMAIL_REGEXP)
      errors.add(:base, :invalid, message: 'Need an email')
      return false
    end

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
