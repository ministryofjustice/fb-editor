class FormOwnerSettings
  include ActiveModel::Model
  validates :form_owner, presence: true
  attr_accessor :form_owner

  def initialize(service_id:)
    @service_id = service_id
    @form_owner = get_form_owner
  end

  def get_form_owner
    latest_metadata = MetadataApiClient::Service.latest_version(@service_id)
    latest_version = MetadataApiClient::Version.create(service_id: @service_id, payload: latest_metadata)
    latest_version.created_by
  end
end
