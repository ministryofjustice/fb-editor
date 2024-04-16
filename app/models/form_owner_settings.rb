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

    unless email_exists?
      errors.add(:base, :invalid, message: 'User must exist in our user DB')
      return false
    end

    true
  end

  private

  def email_exists?
    emails_array = []
    User.all.map { |user| emails_array << user.email }
    emails_array.uniq.include?(@form_owner)
  end
end
