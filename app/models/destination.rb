class Destination
  include ActiveModel::Model
  include ApplicationHelper
  include DestinationsList
  include MetadataVersion
  attr_accessor :service, :flow_uuid, :destination_uuid

  alias_method :change, :create_version

  def title
    service.find_page_by_uuid(flow_uuid).title
  end

  def metadata
    service.flow[flow_uuid]['next']['default'] = destination_uuid
    service.metadata.to_h.deep_stringify_keys
  end

  def destinations
    all_flow_objects = grid.ordered_flow + detached_objects.flow_objects
    destinations_list(flow_objects: all_flow_objects, current_uuid: flow_uuid)
  end

  def current_destination
    service.flow_object(flow_uuid).default_next
  end

  def main_destinations
    destinations_list(flow_objects: grid.ordered_flow, current_uuid: flow_uuid)
  end

  def detached_destinations
    destinations_list(flow_objects: ordered_detached_objects, current_uuid: flow_uuid)
  end

  private

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end

  def detached_objects
    Detached.new(
      service: service,
      main_flow_uuids: grid.flow_uuids
    )
  end

  def ordered_detached_objects
    all_obj = detached_objects.detached_flows.flatten
    all_obj.select { |obj| obj.is_a?(MetadataPresenter::Flow) }
  end
end
