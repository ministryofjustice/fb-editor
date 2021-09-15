module DestinationsList
  def destinations_list(flow_objects:, current_uuid: nil)
    flow_objects.map { |flow|
      next if invalid_destination?(flow.uuid, current_uuid)

      [flow_title(flow), flow.uuid]
    }.compact.uniq
  end

  def flow_title(flow_object)
    return flow_object.title if flow_object.branch?

    page = service.find_page_by_uuid(flow_object.uuid)
    page.title
  end

  def invalid_destination?(flow_uuid, current_uuid)
    flow_uuid == start_uuid ||
      flow_uuid == confirmation_uuid ||
      flow_uuid == current_uuid
  end

  def start_uuid
    @start_uuid ||= service.start_page.uuid
  end

  def confirmation_uuid
    @confirmation_uuid ||=
      service.pages.find { |page| page.type == 'page.confirmation' }&.uuid
  end
end
