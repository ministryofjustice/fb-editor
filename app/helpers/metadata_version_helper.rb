module MetadataVersionHelper
  def get_version_metadata(publish_service)
    # get the latest version of the metadata because if the version id is missing
    # then the latest version would have been the one published before the
    # version_id column was added to the DB
    if publish_service.version_id.blank?
      return latest_version(publish_service.service_id)
    end

    version = MetadataApiClient::Version.find(
      service_id: publish_service.service_id,
      version_id: publish_service.version_id
    )
    version.metadata
  end

  def latest_version(service_id)
    MetadataApiClient::Service.latest_version(service_id)
  end
end
