class FormOwnerSettings
  include ActiveModel::Model
  attr_accessor :form_owner, :service_id, :metadata

  def update
    if @form_owner.blank?
      errors.add(:base, :invalid, message: I18n.t('activemodel.errors.models.transfer_ownership.blank'))
      return false
    end

    unless @form_owner.match(URI::MailTo::EMAIL_REGEXP)
      errors.add(:base, :invalid, message: I18n.t('activemodel.errors.models.transfer_ownership.invalid'))
      return false
    end

    unless email_exists?
      errors.add(:base, :invalid, message: I18n.t('activemodel.errors.models.transfer_ownership.unknown_user'))
      return false
    end

    version = MetadataApiClient::Version.create(service_id:, payload: new_metadata)
    if version.errors?
      errors.add(:base, :invalid, message: version.errors)
      return false
    else
      @version = version
    end
    true
  end

  private

  def email_exists?
    @new_user_id = User.all.map { |user|
      user.id if @form_owner.match(Regexp.new(user.email, Regexp::IGNORECASE))
    }.compact.first
    @new_user_id.present?
  end

  def new_metadata
    @metadata.merge(created_by: @new_user_id)
  end
end
