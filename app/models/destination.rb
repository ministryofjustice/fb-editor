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

  def destinations
    (pages + branches).map { |item| [item.title, item.uuid] }
  end

  def current_destination
    service.flow_object(flow_uuid).default_next
  end

  private

  def pages
    service.pages.reject do |page|
      page.type.in?(INVALID_DESTINATIONS) || page.uuid == flow_uuid
    end
  end

  def branches
    service.branches.sort_by(&:title)
  end
end
