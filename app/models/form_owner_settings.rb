class FormOwnerSettings
  include ActiveModel::Model
  validates :form_owner, presence: true
  attr_accessor :form_owner

  def initialize(service_id:)
    @service_id = service_id
    @form_owner = get_form_owner_email
  end

  private

  def get_form_owner_email
    latest_metadata = MetadataApiClient::Service.latest_version(@service_id)
    latest_version = MetadataApiClient::Version.create(service_id: @service_id, payload: latest_metadata)
    owner_id = latest_version.created_by
    owner_email = User.where(id: owner_id).pick(:email)
    EncryptionService.new.decrypt(owner_email)
  end
end
