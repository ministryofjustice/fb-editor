class Destination
  include ActiveModel::Model
  include DestinationsList
  include MetadataVersion
  attr_accessor :service, :flow_uuid, :destination_uuid

  alias_method :change, :create_version

  def metadata
    service.flow[flow_uuid]['next']['default'] = destination_uuid
    service.metadata.to_h.deep_stringify_keys
  end

  def destinations
    all_flow_objects = ordered_flow + detached
    destinations_list(flow_objects: all_flow_objects, current_uuid: flow_uuid)
  end

  def current_destination
    service.flow_object(flow_uuid).default_next
  end

  private

  def ordered_flow
    @ordered_flow ||= OrderedFlow.new(service: service).build
  end

  def detached
    Detached.new(service: service, ordered_flow: ordered_flow).flow_objects
  end
end
