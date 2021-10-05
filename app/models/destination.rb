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
    all_flow_objects = grid.ordered_flow + detached_objects
    destinations_list(flow_objects: all_flow_objects, current_uuid: flow_uuid)
  end

  def current_destination
    service.flow_object(flow_uuid).default_next
  end

  private

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end

  def detached_objects
    Detached.new(service: service, main_flow_uuids: grid.flow_uuids).flow_objects
  end
end
