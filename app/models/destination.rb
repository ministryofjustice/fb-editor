class Destination
  include ActiveModel::Model
  include MetadataVersion
  attr_accessor :service, :flow_uuid, :destination_uuid

  INVALID_DESTINATIONS = %w[page.start page.confirmation].freeze

  alias_method :change, :create_version

  def metadata
    service.flow[flow_uuid]['next']['default'] = destination_uuid
    service.metadata.to_h.deep_stringify_keys
  end
end
