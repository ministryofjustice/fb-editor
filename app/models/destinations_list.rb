module DestinationsList
  def destinations_list(flow_objects:, current_uuid: nil)
    flow_objects.map { |flow|
      next if invalid_destination?(flow.uuid, current_uuid)

      [flow_title(flow), flow.uuid]
    }.compact.uniq
  end

  def invalid_destination?(flow_uuid, current_uuid)
    if current_uuid == checkanswers_uuid
      flow_uuid != confirmation_uuid
    else
      flow_uuid == start_uuid ||
        flow_uuid == confirmation_uuid ||
        flow_uuid == current_uuid
    end
  end

  def start_uuid
    @start_uuid ||= service.start_page.uuid
  end

  def confirmation_uuid
    @confirmation_uuid ||=
      service.pages.find { |page| page.type == 'page.confirmation' }&.uuid
  end

  def checkanswers_uuid
    @checkanswers_uuid ||=
      service.pages.find { |page| page.type == 'page.checkanswers'}&.uuid
  end
end
