module MetadataVersion
  def create_version
    version = MetadataApiClient::Version.create(
      service_id: service.service_id,
      payload: metadata
    )

    if version.errors?
      errors.add(:base, :invalid, message: version.errors)
      false
    else
      @version = version
    end
  end
end
