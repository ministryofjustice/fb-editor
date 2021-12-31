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
    @metadata ||= begin
      service.flow[flow_uuid]['next']['default'] = destination_uuid
      service.metadata.to_h.deep_stringify_keys
    end
  end

  def destinations
    all_flow_objects = grid.ordered_flow + detached_objects
    destinations_list(flow_objects: all_flow_objects, current_uuid: flow_uuid)
  end

  def current_destination
    service.flow_object(flow_uuid).default_next
  end

  def cya_and_confirmation_present?
    grid.flow_uuids.include?(service.checkanswers_page.uuid) &&
      grid.flow_uuids.include?(service.confirmation_page.uuid)
  end

  def checkanswers_detached?
    !grid.flow_uuids.include?(service.checkanswers_page.uuid)
  end

  def confirmation_detached?
    !grid.flow_uuids.include?(service.confirmation_page.uuid)
  end

  private

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end

  def detached_objects
    Detached.new(service: service, main_flow_uuids: grid.flow_uuids).flow_objects
  end
end
